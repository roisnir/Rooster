const moment = require('moment');
const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();
const db = admin.firestore();
const FormData = require('form-data');
const https = require('https');


class ReportLog{
    constructor(user, status, msg='', time=moment()) {
        this.user = user;
        this.status = status;
        this.msg = msg
        this.time = time;
    }

    format(){
        if (this.status)
            return `[${this.time.format('YYYY-MM-DDTHH:mm:ss')}] Reported ${this.user.userId} successfully: ${this.msg}`;
        return `[${this.time.format('YYYY-MM-DDTHH:mm:ss')}] An error occurred while reporting ${this.user.userId}: ${this.msg}`;
    }

    toString(){
        return this.format();
    }
}

function sendRequest(options, manipulations=(req)=>{}){
    return new Promise((resolve, reject) => {
        const res = {data: ''};
        const req = https.request(
            options,
            (_res) => {
                _res.setEncoding('utf8');
                _res.on('data', (chunk) => {
                    res.data += chunk;
                })
                _res.on('end', () => {
                    res.response=_res;
                    resolve(res);
                })
            }
        );
        req.on('error', (e) => reject(e));
        manipulations(req);
        req.end();
    });
}

async function reportUser (user) {
    const cookieString = user.cookies.map((c)=>c.split(';')[0]).join(';');
    const formData = new FormData();
    formData.append('MainCode', '01');
    formData.append('SecondaryCode', '01');
    try {
        const {response, data} = await sendRequest(
            {
                hostname: 'one.prat.idf.il',
                port: 443,
                path: '/api/Attendance/InsertPersonalReport',
                method: 'POST',
                headers: formData.getHeaders({Cookie: cookieString})
            },
            (req) => formData.pipe(req)
        );
        if (!(200 <= response.statusCode < 300))
            return new ReportLog(user, false, `Request failed with error code ${response.statusCode}: ${data}`);
        console.log(`Status: ${response.statusCode}`);
        console.log(`Headers: ${JSON.stringify(response.headers)}`);
        console.log(`Data: ${data}`);
        return new ReportLog(user, true, 'whoohoo');
    }
    catch (e) {
        return new ReportLog(user, false, e);
    }

}


async function reportAllUsers (){
    const users = await db.collection('users').where('autoReportEnabled', '==', true).get();
    if (users.empty){
        functions.logger.info('no enabled users found');
        return [];
    }
    const resultsPromises = users.docs.map(async (userDoc) => {
        try {
            let user = userDoc.data();
            user.userId = userDoc.id;
            let result = await reportUser(user);
            if (result.status) {
                await userDoc.ref.set({lastReportedAt: admin.firestore.Timestamp.fromMillis(result.time.valueOf())}, {merge: true});
                functions.logger.info(result.toString());
            } else
                functions.logger.error(result.toString());
            return result;
        }
        catch (e) {
            let result = new ReportLog({userId: userDoc.id}, false, `Could not report user. error: ${e}`);
            functions.logger.error(result.toString());
            return result;
        }
    });
    return await Promise.all(resultsPromises).catch((reason => {
        functions.logger.error(`failed reporting users ${reason}`);
        return reason;
    }));
}


exports.reportPresence = functions.pubsub.schedule('42 8 * * 0,1,2,3,4')
    .timeZone('Asia/Jerusalem')
    .onRun((context => {
        functions.logger.info('Task started!');
        return reportAllUsers();
    }));
