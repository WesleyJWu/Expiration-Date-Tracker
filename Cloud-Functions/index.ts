import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import * as database from "firebase/database";
import * as moment from "moment";

// @ts-expect-error -> nodemailer doesn't support typescript.
import * as nodemailer from "nodemailer";

const APP_NAME = "Expiration List IOS";
const mailTransport = nodemailer.createTransport({
    service: "gmail",
    auth: {
        user: "expirationlisttracker@gmail.com",
        pass: "vwterkwplumkzoll",
    },
});

admin.initializeApp();

exports.sendItemEmailsEverySunday = functions.pubsub.schedule("0 0 * * SUN")
    .timeZone("America/Los_Angeles") // Users can choose timezone - default is America/Los_Angeles
    .onRun((context) => {
        const userRef = admin.database().ref("users/");

        // Get the user reference.
        database.get(userRef).then((userSnapshot) => {
            // Look for each UID.
            userSnapshot.forEach((uidSnapshot) => {
                const currentUID = uidSnapshot.key;
                console.log("\tLooking at UID: " + currentUID);

                const locations = {};
                let anyItemExpiredorExpiringSoon = false;

                // Look through each location under the UID.
                uidSnapshot.forEach((locationSnapshot) => {
                    const currentLocation = locationSnapshot.key as string;
                    console.log("\t\tLooking at location: " + currentLocation);

                    const expiredItems = {
                        names: [] as string[],
                        expirationDates: [] as string[],
                        daysRemaining: [] as number[],
                    };

                    const expiringSoonItems = {
                        names: [] as string[],
                        expirationDates: [] as string[],
                        daysRemaining: [] as number[],
                    };

                    // Look at each item under the current location.
                    locationSnapshot.forEach((itemSnapshot) => {
                        const item = itemSnapshot.val();
                        console.log("\t\t\t" + item.ItemName + " Expiration Date: " + item.ExpirationDateYearMonthDay);

                        // Add the item to the relevant dictionaries.
                        const expirationResult = daysUntilExpiration(item.ExpirationDateYearMonthDay);
                        const daysRemaining = expirationResult[0] as number;
                        const expirationDate = expirationResult[1] as string;
                        if (daysRemaining < 0) {
                            // Item is already expired.
                            expiredItems.names.push(item.ItemName);
                            expiredItems.expirationDates.push(expirationDate);
                            expiredItems.daysRemaining.push(daysRemaining);
                            anyItemExpiredorExpiringSoon = true;
                        } else if (daysRemaining < 7) {
                            expiringSoonItems.names.push(item.ItemName);
                            expiringSoonItems.expirationDates.push(expirationDate);
                            expiringSoonItems.daysRemaining.push(daysRemaining);
                            anyItemExpiredorExpiringSoon = true;
                        }
                    });

                    locations[currentLocation] = {
                        expiredItems: expiredItems,
                        expiringSoonItems: expiringSoonItems,
                    };
                });

                // Send email only if there is something that is expiring soon or expired already.
                if (anyItemExpiredorExpiringSoon) {
                    admin.auth().getUser(currentUID as string).then(function(userRecord) {
                        console.log(`The user's email is: ${userRecord.email}`);
                        sendEmail(userRecord.email as string, userRecord.email as string, locations);
                    });
                }
            });
            console.log("Successfully got through all users!");
        });
    });


async function sendEmail(email: string, displayName: string, locations: object) {
    const mailOptions = {
        from: `${APP_NAME} <noreply@firebase.com>`,
        to: email,
    };

    // @ts-expect-error -> nodeMailer doesn't support typescript
    mailOptions.subject = "Weekly Expired and Expiring Items.";
    // @ts-expect-error -> nodeMailer doesn't support typescript
    mailOptions.html = generateItemsEmail(displayName, locations);
    await mailTransport.sendMail(mailOptions);
}

// Generate HTML Email
function generateItemsEmail(recipientName: string, locations: object) {
    // Generate the HTML for the email template
    const htmlHeader =
        `
      <html>
        <body style="font-family: Arial, sans-serif; color: #333;">
          <h1 style="text-align: center; margin: 20px 0;">Expiring Items Reminder</h1>
          <p style="margin: 20px 0; font-size: 14px;">Hello ${recipientName},</p>
          <p style="margin: 20px 0; font-size: 14px;">Here are the items that have expired or are expiring this week:</p>
    `;

    const htmlFooter =
        `
        <p style="margin: 20px 0; font-size: 14px;">Best,</p>
        <p style="margin: 20px 0; font-size: 14px;">Expiration List Tracker</p>
        </body>
        </html>
    `;

    let htmlBody = "";
    for (const [locationName, expiringLists] of Object.entries(locations)) {
        const expiredItems = expiringLists.expiredItems;
        const expiringSoonItems = expiringLists.expiringSoonItems;
        const expiredItemsHtml = arrayToHtmlList(expiredItems.names, expiredItems.expirationDates, expiredItems.daysRemaining);
        const expiringSoonItemsHtml = arrayToHtmlList(expiringSoonItems.names, expiringSoonItems.expirationDates, expiringSoonItems.daysRemaining);

        htmlBody +=
            `
        <div style="margin: 20px 0; padding: 20px; background-color: #f5f5f5; border-radius: 5px;">
            <h1 style="font-size: 18px; margin: 5px 0;">${locationName}</h1>
            <div style="margin: 20px 0; padding: 20px; background-color: #fafafa; border-radius: 5px;">
            <h2 style="font-size: 14px; margin: 10px 0;">${expiredItemsHtml.length != 58 ? "Expired Items" : ""}</h2>
            ${expiredItemsHtml}
            <h2 style="font-size: 14px; margin: 10px 0;">${expiringSoonItemsHtml.length != 58 ? "Expiring Soon" : ""}</h2>
            ${expiringSoonItemsHtml}
            </div>
        </div>
        `;
    }

    // Return the HTML string
    return htmlHeader + htmlBody + htmlFooter;
}

function arrayToHtmlList(itemNames: string[], expirationDates: string[], daysRemaining: string[]) {
    // Create the opening tag for the list
    let listHtml = "<ul style=\"list-style: none; margin: 0; padding: 0;\">";

    // Iterate through the arrays, creating a list item for each element and combining the item name, expiration date, and days remaining
    for (let i = 0; i < itemNames.length; i++) {
        listHtml += `
      <li style="display: flex; align-items: center; margin-bottom: 10px;">
        <div style="width: 100%;">
          <span style="font-weight: bold; font-size: 16px; color: #333;">${itemNames[i]}</span>
          <span style="font-style: italic; color: #999; margin-left: 10px;">| ${daysRemaining[i]} days</span>
          <div style="height: 1px; width: 28%; background-color: #ddd; margin: 10px 0;"></div>
          <span style="font-size: 12px; color: #777;">Expiration Date: ${expirationDates[i]}</span>
        </div>
      </li>`;
    }

    // Add the closing tag for the list
    listHtml += "</ul>";

    // Return the HTML string
    return listHtml;
}

function daysUntilExpiration(ExpirationDateYearMonthDay: string) {
    // Converts the YY/MM/dd to a moment object
    const expirationDate = moment(ExpirationDateYearMonthDay, "YY/MM/DD");
    const todaysDate = moment();
    // Returns the difference btw Expiration Date and Today's Date
    // Returns the date in a MM-DD-YY format
    return [expirationDate.diff(todaysDate, "days"), expirationDate.format("MM/DD/YYYY")];
}
