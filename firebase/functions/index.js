const functions = require('firebase-functions');


exports.reportPresese = functions.pubsub.schedule('42 8 * * *')
    .timeZone('Asia/Jerusalem')
    .onRun((context => {
        functions.logger.info('Task runs!');
        return null;
    }));
