const env = process.env;

const AWS = require('aws-sdk');

exports.handler = (event, context) => {
  event.Records.forEach(record => {
    console.log(new Date(parseInt(record.Sns.Message, 10)));
  });
};
