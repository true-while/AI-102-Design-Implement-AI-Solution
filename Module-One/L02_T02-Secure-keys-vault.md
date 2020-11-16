# Exercise: Access Cognitive Services key from Azure Key Vault

You will need an Azure Key Vault instance within your subscription and environment. Follow these steps to create an Azure Key Vault instance in the Azure portal:

1. Sign in to https://portal.azure.com/.
1. In the left pane, select Create a resource.
1. In the search box, enter **Key Vault** and select the **Key Vault** service.
1. From the **Key Vault** page, select **Create**.
1. Provide a unique value for **Key vault name**.
1. Select the same resource group and region in which your Cognitive Services instance is deployed.

    ![Screenshot showing Key Vault create, highlighting resource group and Key vault name fields.](media/02-key-vault-create.png)

1. Select **Review + create**.

Now let’s create the secret cognitive-services-subscription-key in the Azure Key Vault instance using the Azure portal:

1. Navigate to your Key Vault instance.
1. In the left navigation pane, select **Secrets** (in the Settings section).

    ![Screenshot of Secrets setting in Key Vault](media/02-key-vault-secrets-button.png)

1. Select **+ Generate/Import** and add the secret **Name** and **Value**. Provide secret name `cognitive-services-subscription-key` and value as key of your cognitive service deployed on previous step. Then select **Create**.

    ![Screenshot showing add secret pane with Name and Value populated.](media/02-key-vault-secret-name-value.png)

1. Your application will retrieve the development service **endpoint** and **Key Vault** name from environment variables. Set the environment variables for your session using console window (bash) with the following command. Replace `<key-vault-name>` with short name of the keyvaul. Then replace `<endopint-name>` with the endpoint value for your service deployed previously. You can run following command from terminal in VS code (Windows).

    ```bash
    $Env:KEY_VAULT_NAME='<key-vault-name>'
    $Env:COGNITIVE_SERVICE_ENDPOINT='<endopint-name>'
    ```
1. You can verify how the variables is set by run following command: 

    ```bash
    python -c "import os; print(os.environ['COGNITIVE_SERVICE_ENDPOINT'])"
    ```

## Set up credential to access Key Vault

Now you need access to Azure Key Vault from your application.  In your code, you will use the **DefaultAzureCredential** class. The class is used because it provides several options for authenticating: as a **Service Principal**, using **Managed Identity**, or with cached user credentials. In this example, you will use a Service Principal.

Let’s create the Service Principal we will use for authentication.

1. To create a service principal with owner role on the resource group, run the following Azure CLI command. Replace `<new-sp-name>` with a new service principal name. Also replace `<subscription-id>` and `<resource-group>` with the correct values for your environment. You can find `subscription id` by run command `az account show`

    ```azurecli
    az ad sp create-for-rbac -n "https://<new-sp-name>" --role owner --scopes subscriptions/<subscription-id>/resourceGroups/<resource-group>
    ```

    The output of this command has a few key items you will need in the next steps:

    ```azurecli
    {
      "appId": "e0ff50a7-37c3-42a6-89f1-671a9522fea6",
      "displayName": "cog-svc-sp",
      "name": "https://cog-svc-sp",
      "password": "6EVasWN9rL09wJSQ7fHdEG1q0IUFR-Fa98",
      "tenant": "9fb711111-59aa-466b-cdac-e5805a51bbaa"
    }
    ```

1. For DefaultAzureCredential to work with your service principal, set the following environment variables by replacing `<appId>`, `<tenant>`, and, `<password>` with the output from the previous step.

    ```azurecli
    $Env:AZURE_CLIENT_ID='<appId>'
    $Env:AZURE_TENANT_ID='<tenant>'
    $Env:AZURE_CLIENT_SECRET='<password>'
    ```

    The Service Principal password should be kept secret so setting an environment variable is not ideal. It is intended to be a development solution only. When your application is deployed to Azure, the preferred approach is to use a Managed Identity instead of saving the Service Principal password in an environment variable.

1. To add permissions for your new service principal to access Key Vault, run the following Azure CLI command with <new-sp-name> replaced with the same value you provided when creating the service principal.

    ```azurecli
    az keyvault set-policy -n $Env:KEY_VAULT_NAME --spn "https://<new-sp-name>" --secret-permissions get list
    ```

## Use Key Vault secrets in your application

Now that Azure Key Vault is storing the subscription key, you need to add code to your project that will retrieve that key. Before you can include that in your project, you need to import the appropriate libraries. In this example, use the **TextAnalyticsClient** library for the **Text Analytics Cognitive Service**, but this will work for any of the services.

## Python 

1. To test your service from python in your VS code create new file `test.py` with following content. 

    ```python
    import os
    from azure.core.credentials import AzureKeyCredential
    from azure.keyvault.secrets import SecretClient
    from azure.identity import DefaultAzureCredential

    from azure.ai.textanalytics import TextAnalyticsClient

    # Next the code will retrieve the required values from environment variables and set the Key Vault Uri.

    service_endpoint = os.environ["COGNITIVE_SERVICE_ENDPOINT"]
    key_vault_name = os.environ["KEY_VAULT_NAME"]
    key_vault_uri = f"https://{key_vault_name}.vault.azure.net/"

    # Now you can authenticate with DefaultAzureCredential and retrieve the subscription key from Azure Key Vault. 
    # The DefaultAzureCredential() instance is using the Service Principal environment variables you configured previously: 
    # AZURE_CLIENT_ID, AZURE_TENANT_ID, AZURE_CLIENT_SECRET.
    credential = DefaultAzureCredential()
    secret_client = SecretClient(key_vault_uri, credential)
    subscription_key = secret_client.get_secret("cognitive-services-subscription-key").value

    # Here you are using the subscription key which was retrieved from Key Vault to authenticate a Cognitive Services client.
    cg_credential = AzureKeyCredential(subscription_key)
    client = TextAnalyticsClient(service_endpoint, cg_credential)

    # Your client is ready to use. Add a simple command using key phrase extraction to test it out.
    documents = ["If I cannot do great things, I can do small things in a great way."]
    response = client.extract_key_phrases(documents)[0]
    print("Key phrases:")
    for keyphrase in response.key_phrases:
      print(f"\t{keyphrase}")
    ```

1. From the VS code console run following commands to install required packages. 

    ```bash
    pip install azure-ai-textanalytics
    pip install azure-keyvault-secrets
    pip install azure-identity
    ```

1. To test the script select "Run" command from VS code menu.

1. The output should return following: 

    ```bash
    Key phrases:
            great things
            small things
            great way
    ```

## C#

1. To test your service from C# in your VS code create new file `test.cs` with following content. 

    ```csharp
    using System;
    using Azure;
    using static System.Environment;
    using Azure.Identity;
    using Azure.Security.KeyVault.Secrets;

    using Azure.AI.TextAnalytics;

    // Next the code will retrieve the required values from environment variables and set the Key Vault Uri.
    var serviceEndpoint = GetEnvironmentVariable("COGNITIVE_SERVICE_ENDPOINT");
    var keyVaultName = GetEnvironmentVariable("KEY_VAULT_NAME");
    var keyVaultUri = new Uri($"https://{keyVaultName}.vault.azure.net/");

    // Now you can authenticate with DefaultAzureCredential and retrieve the subscription key from Azure Key Vault. 
    // The DefaultAzureCredential() instance is using the Service Principal environment variables you configured previously: 
    // AZURE_CLIENT_ID, AZURE_TENANT_ID, AZURE_CLIENT_SECRET.
    var keyVaultClient = new SecretClient(keyVaultUri, new DefaultAzureCredential());
    KeyVaultSecret subscriptionKey = keyVaultClient.GetSecret("cognitive-services-subscription-key");

    // Here you are using the subscription key which was retrieved from Key Vault to authenticate a Cognitive Services client.
    AzureKeyCredential credentials = new AzureKeyCredential(subscriptionKey.Value);
    var client = new TextAnalyticsClient(new Uri(serviceEndpoint), credentials);

    // Your client is ready to use. Add a simple command using key phrase extraction to test it out.
    var response = client.ExtractKeyPhrases("If I cannot do great things, I can do small things in a great way.");
    Console.WriteLine("Key phrases:");
    foreach (string keyphrase in response.Value)
    {
        Console.WriteLine($"\t{keyphrase}");
    }
    ```

1. Create a new file proj.csproj with following content: 

    ```XML
    <Project Sdk="Microsoft.NET.Sdk.Web">

        <PropertyGroup>
            <TargetFramework>netcoreapp3.1</TargetFramework>
            <LangVersion>preview</LangVersion>
        </PropertyGroup>

        <ItemGroup>
        </ItemGroup>

        <ItemGroup>
          <PackageReference Include="Azure.AI.TextAnalytics" Version="5.0.0" />
          <PackageReference Include="Azure.Identity" Version="1.3.0" />
          <PackageReference Include="Azure.Security.KeyVault.Secrets" Version="4.1.0" />
        </ItemGroup>

    </Project>
    ```
1. From the VS code console run following commands to build and install required packages. 

    ```bash
    dotnet build
    ```

1. To test the script select "Run" command from VS code menu.

1. The output should return following: 

    ```bash
    Key phrases:
            great things
            small things
            great way
    ```