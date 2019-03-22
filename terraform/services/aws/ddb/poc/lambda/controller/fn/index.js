const env = process.env;
const AWS = require('aws-sdk');

const lambda = new AWS.Lambda();
const sns = new AWS.SNS();

exports.handler = (event, context) => {
  return new Promise(async(resolve, reject) => {
    try {
      event.Records.forEach(async(record, idx) => {
        if (!idx) {
          // NOTE: This is the first record of the payload and we have preserved
          // the full 30 second time limit for the execution of this λ
          const id = record.dynamodb.NewImage.partitionId.S;
          const params = {
            Message: JSON.stringify({
              partitionId: record.dynamodb.NewImage.partitionId.S
            }),
            MessageStructure: 'string',
            TopicArn: env.AWS_TOPIC_ARN
          };

          const topic = sns.publish(params).promise();
          topic.then(data => {
            resolve(data);
          }).catch(reject);
        } else {
          // NOTE: By default λ has a 30 second execution limit, this record
          // is not the first of the payload, re-call the λ function recursively
          // in order to preserve the full 30 second execution time limit
          event.Records = [record];

          const params = {
            FunctionName: context.functionName,
            InvocationType: 'Event',
            Payload: JSON.stringify(event),
            Qualifier: context.functionVersion
          }

          const invoke = lambda.invoke(params).promise();
          invoke.then(data => {
            resolve(data)
          }).catch(reject);
        }
      });
    } catch (error) {
      reject(error);
    }
  });
}
