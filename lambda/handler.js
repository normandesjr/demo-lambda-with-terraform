'use strict';

const AWS = require('aws-sdk');
AWS.config.update({region: process.env.region});

module.exports.sendNotificationToSQS = async (event, context) => {
  const time = new Date();
  console.log(`The cron function "${context.functionName}" ran at ${time}`);

  const sqs = new AWS.SQS({apiVersion: '2012-11-05'});

  console.log('event', event.job);
  console.log('context', context);

  const params = {
    MessageBody: `${time}`,
    QueueUrl: process.env.sqsUrl
  };

  await sqs.sendMessage(params).promise();
};