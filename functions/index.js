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
        body: 'A temperatura excedeu 30°C. Atualmente estão ' + temperatura + '°C.'
      },
      topic: 'high_temperature'
    };

    try {
      await admin.messaging().send(message);
      console.log('Notificação enviada com sucesso!');
    } catch (error) {
      console.error('Erro ao enviar notificação:', error);
    }

  } else if (temperatura < 10) {
    const message = {
      notification: {
        title: 'Alerta de Temperatura!',
        body: 'A temperatura está abaixo de 10°C. Atualmente estão ' + temperatura + '°C.'
      },
      topic: 'low_temperature'
    };

    try {
      await admin.messaging().send(message);
      console.log('Notificação enviada com sucesso!');
    } catch (error) {
      console.error('Erro ao enviar notificação:', error);
    }
  }
}


async function sendHumidityNotification(humidadeAr) {
  if (humidadeAr > 50) {
    const message = {
      notification: {
        title: 'Alerta de Humidade no Ar!',
        body: 'A humidade excedeu 50%. Atualmente estão ' + humidadeAr + '%.'
      },
      topic: 'high_humidity'
    };

    try {
      await admin.messaging().send(message);
      console.log('Notificação enviada com sucesso!');
    } catch (error) {
      console.error('Erro ao enviar notificação:', error);
    }

  } else if (humidadeAr < 10) {
    const message = {
      notification: {
        title: 'Alerta de Humidade no Ar!',
        body: 'A humidade está abaixo de 10%. Atualmente estão ' + humidadeAr + '%.'
      },
      topic: 'low_humidity'
    };

    try {
      await admin.messaging().send(message);
      console.log('Notificação enviada com sucesso!');
    } catch (error) {
      console.error('Erro ao enviar notificação:', error);
    }
  }
}

exports.sendTemperatureNotification = sendTemperatureNotification;
exports.sendHumidityNotification = sendHumidityNotification;

exports.triggerNotificationOnCreate = onDocumentCreated(
  { path: "/dados/{documentId}", region: "europe-west1" },
  async (event) => {
    const temperatura = event.data.data().temperatura;
    const humidadeAr = event.data.data().humidadeAr;
    logger.log("temperatura", event.params.documentId, temperatura);
    await sendTemperatureNotification(temperatura);
    logger.log("humidadeAr", event.params.documentId, humidadeAr);
    await sendHumidityNotification(temperatura);

  });