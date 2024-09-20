import { type Command, Argument } from 'commander'
import c from 'picocolors'
import { fromIni } from '@aws-sdk/credential-provider-ini'
import querystring from 'node:querystring'
import { ofetch } from "ofetch";
import open from "open";


export const SetupAwsConsoleLoginCommand = (program: Command): void => {
  program.command('aws-console')
    .description('use aws cli permissions to open aws console')
    .argument('[profile]', 'aws profile name', 'default')
    .action(async (args) => {


      try {
        const identity = await fromIni(args.profile)()

        console.log(c.blue(`Setting up AWS Console Login for profile: ${args.profile}`));

        const url_credentials = {
          sessionId: identity.accessKeyId,
          sessionKey: identity.secretAccessKey,
          sessionToken: identity.sessionToken
        }

        const urlPrameters = {
          'Action': 'getSigninToken',
          'DurationSeconds': 43200,
          'Session': JSON.stringify(url_credentials)
        }

        const request_url = "https://signin.aws.amazon.com/federation?" + querystring.encode(urlPrameters)
        const response = await ofetch(request_url, { parseResponse: JSON.parse })

        console.log(c.blue(`succesful got sign In Token`))


        const loginUrlParams = {
          'Action': 'login',
          'Destination': 'https://console.aws.amazon.com/',
          'SigninToken': response.SigninToken,
          'Issuer': 'https://example.com'
        }

        const loginUrl = "https://signin.aws.amazon.com/federation?" + querystring.encode(loginUrlParams);

        console.log(c.yellow('Opening Url in Browser'))
        await open(loginUrl, { wait: false });

      } catch (error) {
        console.error(c.red('Error trying to login with AWS credentials'));
        process.exit(1);
      }


      console.log('')
      console.log(c.green('Done!'))
    })
}
