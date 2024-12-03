const { logger } = require("firebase-functions");
const { initializeApp } = require("firebase-admin/app");
const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const admin = require('firebase-admin');


initializeApp();

async function sendTemperatureNotification(temperatura) {
  if (temperatura > 30) {
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
}

exports.sendTemperatureNotification = sendTemperatureNotification; // Make it callable

exports.triggerNotificationOnHighTemperature = onDocumentCreated("/dados/{documentId}", async (event) => {
  const temperatura = event.data.data().temperatura;
  logger.log("HighTemperature", event.params.documentId, temperatura);
  await sendTemperatureNotification(temperatura); // Call the separate function
});