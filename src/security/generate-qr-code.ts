import * as express from 'express';
import * as functions from 'firebase-functions';
import * as qrcode from 'qrcode';

const app = express();

app.get('', async (req, res) => {
    const url = req.query["url"];
    console.log(url);
    await qrcode.toFileStream(res, url);
})

var generateQrCode = { default: functions.https.onRequest(app) }

export { generateQrCode };