## Sign up for Video Indexer free tier

If you don’t already have a **Video Indexer** account, you can create a free trial account to get started. The following steps walk you through going to the **Video Indexer portal** and getting setup.

1. Open your browser and go to [**Video Indexer Portal**](https://api-portal.videoindexer.ai).
1. Log in using a personal account (Personal Microsoft account, LinkedIn, Google, Facebook).
1. Expand the left pane and select **Account Settings**.

    ![Screen shot highlight the “Account settings” option on the Video Indexer Portal.](media/video-indexer-portal-account-settings-ssm.png)

1. On the **Account Settings** page, copy and save the **Account ID**. You will need the information in the next section.

## Gather API Key

Throughout this module, you will be using the **Video Indexer API**. However, to set up your API calls you will need to use the **Video Indexer Developer Portal**. From the developer portal you can find existing API subscriptions, add new API subscriptions, and retrieve credentials needed for programmatic access.

You found your **Account ID** in the account creation steps. Now let’s get the **API Key, which is required for API authorization.

Retrieve your **API key** from the developer portal by following these steps. Remember to keep this key secret.

1. Use your browser to sign in to [Video Indexer portal](https://api-portal.videoindexer.ai). Log in with the same account (and provider) used to sign up for the trial account.

    ![Screen shot of Video Indexer Developer Portal highlighting sign-in link on top right.](media/video-indexer-dev-portal-sign-in-ssm.png)

1. Go to the **Products** tab, then select **Authorization**.

    ![Screen shot of Products tab with Authorization link highlighted.](media/video-indexer-dev-portal-products-authorization-ssm.png)

1. From the **Authorization** page, select the **Product Authorization** subscription that was automatically created for you. If one was not already created, select **Add subscription** and complete the subscription process.

    ![Screen shot of Authorization page with Product Authorization subscription link highlighted.](media/video-indexer-dev-portal-authorization-subscription-ssm.png)

1. In the **Your subscriptions** section, choose **Show** to temporarily see your key. Copy that value to be used in the next steps.

    ![Screen shot of subscription page with Show option highlighted under the Primary Key section.](media/video-indexer-dev-portal-authorization-show-key-ssm.png)

    To use the API, you will need to set an **Account ID**, **Location**, and **API Key**. The examples in this module all read these from environment variables so that these values do not need to be hard-coded. Let’s set these values now.

1. Set these environment variables, replacing <account_id> and <api_key> with your own values. If you are not using a trial account, replace trial with the Azure region used for your account. Your code will reference these values so make sure they are set within the same session you run the code.

    ```bash
    export VIDEO_INDEXER_ACCOUNT=<account_id>
    export VIDEO_INDEXER_API_KEY=<api_key>
    export VIDEO_INDEXER_LOCATION=trial
    ```

    ```dos
    set VIDEO_INDEXER_ACCOUNT= <account_id>
    set VIDEO_INDEXER_API_KEY=<api_key>
    set VIDEO_INDEXER_LOCATION=trial
    ```

    ```powershell
    $env:VIDEO_INDEXER_ACCOUNT = '<account_id>'
    $env:VIDEO_INDEXER_API_KEY = '<api_key>'
    $env:VIDEO_INDEXER_LOCATION = '<trial>'
    ```
