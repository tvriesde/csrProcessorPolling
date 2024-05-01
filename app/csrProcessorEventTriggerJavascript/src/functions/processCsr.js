const { app } = require('@azure/functions');
const { DefaultAzureCredential } = require("@azure/identity");
const { CertificateClient } = require("@azure/keyvault-certificates");

const credential = new DefaultAzureCredential();

// Build the URL to reach your key vault
const vaultName = "vaultrsh5rk6qw5tjm";
const url = `https://${vaultName}.vault.azure.net`;

const client = new CertificateClient(url, credential);


async function getCertificate(certificateName) {
    const latestCertificate = await client.getCertificate(certificateName);
    console.log(`Latest version of the certificate ${certificateName}: `, latestCertificate);
    const specificCertificate = await client.getCertificateVersion(
        certificateName,
        latestCertificate.properties.version
    );
    console.log(
        `The certificate ${certificateName} at the version ${latestCertificate.properties.version}: `,
        specificCertificate
    );
    const operation = await client.getCertificateOperation(certificateName);
    console.log(`CSR: ${operation}`);
}

app.eventGrid('processCsr', {
    handler: async (event, context) => {
        context.log('Event grid function processed event:', event);
        //log the certificate name from the event
        context.log('Certificate name:', event.data.ObjectName);
        try {
            await getCertificate(event.data.ObjectName);
            context.log('done');
        } catch (error) {
            context.log('Error getting certificate:', error);
        }
    }
});
