'use strict';

const AWS = require('aws-sdk');
AWS.config.update({region: process.env.region});
const sqs = new AWS.SQS({apiVersion: '2012-11-05'});

module.exports.sendNotificationToSQS = async (event, context) => {
  const time = new Date();
  console.log(`The cron function "${context.functionName}" ran at ${time}`); 

  console.log('event', event.job);

  const params = {
    MessageBody: `{"jobName": ${event.job}}`,
    QueueUrl: process.env.sqsUrl
  };

  await sqs.sendMessage(params).promise();
};