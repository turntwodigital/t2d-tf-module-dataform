/**
 * Responds to any HTTP request.
 *
 * @param {!express:Request} req HTTP request context.
 * @param {!express:Response} res HTTP response context.
 */

const functions = require('@google-cloud/functions-framework');
const axios = require('axios');

functions.http('main', (req, res) => {
    if (req.method !== 'POST') {
        res.status(405).send('Method Not Allowed');
        return;
    }

    try {
        const body = JSON.parse(req.rawBody);

        if (!body.text || !body.endpoint) {
            res.status(400).send('Missing required properties: text and endpoint');
            return;
        }

        const data = { text: body.text };

        (async () => {
            const res = await axios.post(body.endpoint, data);
        })();

        res.status(res.status).send('Success');

    } catch (error) {
        console.error('Error:', error);
        res.status(500).send('Internal Server Error');
    }
});