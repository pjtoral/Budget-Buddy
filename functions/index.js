const functions = require('firebase-functions');
const admin = require('firebase-admin');
const sgMail = require('@sendgrid/mail');

admin.initializeApp();
const db = admin.firestore();

sgMail.setApiKey(process.env.SENDGRID_API_KEY);
const FROM_EMAIL = process.env.SENDGRID_FROM || 'no-reply@yourdomain.com';
const CODE_TTL_MINUTES = 10;

function generateCode() {
  return Math.floor(100000 + Math.random() * 900000).toString();
}

exports.requestEmailVerificationCode = functions.https.onCall(async (data) => {
  const email = (data.email || '').toLowerCase();
  if (!email) throw new functions.https.HttpsError('invalid-argument', 'Email is required');

  const code = generateCode();
  const now = admin.firestore.Timestamp.now();
  const expiresAt = admin.firestore.Timestamp.fromDate(new Date(Date.now() + CODE_TTL_MINUTES * 60 * 1000));

  // Store code in collection with email as ID-safe key
  const docRef = db.collection('email_verifications').doc(encodeURIComponent(email));
  await docRef.set({ email, code, createdAt: now, expiresAt });

  // Send email via SendGrid
  const msg = {
    to: email,
    from: FROM_EMAIL,
    subject: 'Your Budget Buddy verification code',
    text: `Your verification code is ${code}. It expires in ${CODE_TTL_MINUTES} minutes.`,
    html: `<p>Your verification code is <strong>${code}</strong>.</p><p>It expires in ${CODE_TTL_MINUTES} minutes.</p>`
  };

  await sgMail.send(msg);
  return { success: true };
});

exports.verifyEmailCode = functions.https.onCall(async (data) => {
  const email = (data.email || '').toLowerCase();
  const code = (data.code || '').toString();
  if (!email || !code) throw new functions.https.HttpsError('invalid-argument', 'Email and code are required');

  const docRef = db.collection('email_verifications').doc(encodeURIComponent(email));
  const doc = await docRef.get();
  if (!doc.exists) {
    throw new functions.https.HttpsError('not-found', 'No verification code found for this email');
  }
  const payload = doc.data();
  const now = admin.firestore.Timestamp.now();
  if (payload.expiresAt.toMillis && payload.expiresAt.toMillis() < now.toMillis()) {
    await docRef.delete();
    throw new functions.https.HttpsError('deadline-exceeded', 'Code has expired');
  }
  if (payload.code !== code) {
    throw new functions.https.HttpsError('invalid-argument', 'Code is incorrect');
  }

  // success -> remove doc
  await docRef.delete();
  return { success: true };
});