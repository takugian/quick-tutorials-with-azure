const express = require('express');

const app = express();

const uuid = require('uuid');

const customers = [
    {
        customer_id: '6c84fb90-12c4-11e1-840d-7b25c5ee775a',
        customer_name: 'EMERSON',
        customer_birth_at: '1993-01-22'
    }
];

app.get('/', (req, res) => {

    console.log(`running GET /customers params ${JSON.stringify(req.query)}`);

    if (req.query.customer_name) {
        res.status(200).json({ data: customers.filter(item => item.customer_name === req.query.customer_name) });
        return;
    }

    res.status(200).json({ data: customers });

});

app.post('/', (req, res) => {

    console.log(`running POST /customers body ${JSON.stringify(req.body)}`);

    if (!req.body.customer_name) {
        res.status(400).json({ data: { error_code: "1", error_description: "customer_name is required" } });
        return
    }

    req.body.customer_id = uuid.v1();

    customers.push(req.body);

    res.status(201).setHeader("Location", `/customers/${req.body.customer_id}`).json();

});

app.get('/:customer_id', (req, res) => {

    console.log(`running GET /customers/${req.params.customer_id}`);

    const customer = customers.find(item => item.customer_id === req.params.customer_id);

    if (customer) {
        res.status(200).json({ data: customer });
    } else {
        res.status(404).json();
    }

});

app.put('/:customer_id', (req, res) => {

    console.log(`running PUT /customers/${req.params.customer_id}`);

    const customer = customers.find(item => item.customer_id === req.params.customer_id);

    if (customer) {

        customer.customer_id = req.params.customer_id;
        customer.customer_name = req.body.customer_name;
        customer.customer_birth_at = req.body.customer_birth_at;

        const index = customers.findIndex(item => item.customer_id == req.params.customer_id);
        customers.splice(index, 1);
        customers.push(customer);

        res.status(204).json();

    } else {
        res.status(404).json();
    }

});

app.delete('/:customer_id', (req, res) => {

    console.log(`running DELETE /customers/${req.params.customer_id}`);

    const customer = customers.find(item => item.customer_id === req.params.customer_id);

    if (customer) {
        
        const index = customers.findIndex(item => item.customer_id == req.params.customer_id);
        customers.splice(index, 1);

        res.status(204).json();

    } else {
        res.status(404).json();
    }

});

module.exports = app;