const env = process.env;

const AWS = require('aws-sdk');

exports.handler = (event, context) => {
  event.Records.forEach(record => {
    const payload = JSON.parse(record.Sns.Message);
    const timestamp = parseInt(payload.partitionId, 10);
    const date = new Date(timestamp);

    console.log(date.toString());
  });
};
