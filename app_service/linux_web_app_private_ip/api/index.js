
const express = require('express');
const bodyParser = require('body-parser');

const app = express();

const port = process.env.PORT || 3070;

app.use(bodyParser.json());

app.get('/', (req, res) => {
    console.log('running /');
    res.send();
});

app.use('/', require('./routes/routes'));

app.listen(port, (err) => {
    if (err)
        logger.error('Error', err);
    console.log(`running server on from port ${port}`);
});