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
        const body = req.body;
        const text = body.calls[0][0];
        const endpoint = body.calls[0][1];
        
        if (!text || !endpoint) {
            res.status(400).send('Missing required properties: text and endpoint');
            return;
        }

        const data = { text: text };

        (async () => {
            const res = await axios.post(endpoint, data);
        })();

        res.status(200).json({'replies': 'Notification succesfully processed!'});

    } catch (error) {
        console.error('Error:', error);
        res.status(500).json({'replies': 'Error processing notification.'});
    }
});
