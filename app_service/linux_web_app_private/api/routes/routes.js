const express = require('express');

const apiRouter = express();

apiRouter.use('/customers', require('./customer'));

module.exports = apiRouter;