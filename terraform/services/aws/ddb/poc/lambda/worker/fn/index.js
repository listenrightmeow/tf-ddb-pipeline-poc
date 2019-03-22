const env = process.env;

const AWS = require('aws-sdk');

exports.handler = (event, context) => {
  event.Records.forEach(record => {
    console.log(record.Sns.Message);
  });
};
