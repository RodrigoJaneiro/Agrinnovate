const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

exports.sendNotificationOnHighTemperature = functions.firestore.onDocumentCreated('dados/{documentId}', async (snap, context) => {
    const data = snap.data();
    const temperature = data.temperatura;

    if (temperature > 30) {
      const message = {
        notification: {
          title: 'Alerta de Temperatura!',
          body: 'A temperatura excedeu 30°C.'
        },
        topic: 'high_temperature'
      };

      try {
        await admin.messaging().send(message);
        console.log('Notificação enviada com sucesso!');
      } catch (error) {
        console.error('Erro ao enviar notificação:', error);
      }
    }
  });