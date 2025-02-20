const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

const users = admin.firestore().collection('users');

async function getLicenseDoc(licenseKey) {
  return await users.doc(licenseKey).get();
}

async function isLicenseValid(doc) {
  if (!doc.exists) {
    return { valid: false, expirationDate: null };
  }
  const data = doc.data();
  const expirationDate = data.expirationDate.toDate();
  if (expirationDate < new Date()) {
    console.log('Key expired');
    return { valid: false, expirationDate };
  }
  if (data.use > 0) {
    console.log('Key already used');
    return { valid: false, expirationDate };
  }
  return { valid: true, expirationDate };
}

exports.verifyLicenseKey = functions.https.onCall(async (data, context) => {
  const parsedData = JSON.parse(data["data"]);
  const licenseKey = parsedData.licenseKey;

  if (!licenseKey) {
    throw new functions.https.HttpsError('invalid-argument', 'La clé de licence est manquante.');
  }

  try {
    const doc = await getLicenseDoc(licenseKey);
    const { valid, expirationDate } = await isLicenseValid(doc);
    if (valid) {
      await users.doc(licenseKey).update({
        use: admin.firestore.FieldValue.increment(1)
      });
    }
    return { valid, expirationDate: expirationDate ? expirationDate.toISOString() : null };
  } catch (error) {
    throw new functions.https.HttpsError('internal', 'Erreur lors de la vérification de la clé de licence.');
  }
});

exports.checkValidity = functions.https.onCall(async (data, context) => {
  const parsedData = JSON.parse(data["data"]);
  const licenseKey = parsedData.licenseKey;

  if (!licenseKey) {
    throw new functions.https.HttpsError('invalid-argument', 'La clé de licence est manquante.');
  }

  try {
    const doc = await getLicenseDoc(licenseKey);
    const { valid, expirationDate } = await isLicenseValid(doc);
    return { valid, expirationDate: expirationDate ? expirationDate.toISOString() : null };
  } catch (error) {
    throw new functions.https.HttpsError('internal', 'Erreur lors de la vérification de la clé de licence.');
  }
});
