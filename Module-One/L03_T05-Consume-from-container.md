# Exercise - Consume Cognitive Services from a Container

Let’s run a sample application that connects through the exposed endpoint of our Kubernetes deployment.

1. First, set the environment variables we will use to connect, `CONTAINER_ENDPOINT` and `COGNITIVE_SERVICE_KEY` (if not already set). From VS Code terminal set the environment variables for your session using following command.

    ```cmd
    $Env:CONTAINER_ENDPOINT='https://<EXTERNAL-IP>:5000'
    $Env:COGNITIVE_SERVICE_KEY='<subscription_key>'
    ```

## Python

Let’s run a sample application that consumes from our language detection container:

1. In VS Code create new folder and file `test.py`

1. Import required libraries by run following command in VS code.

    ```cmd
    pip install azure-identity
    pip install azure-ai-textanalytics
    ```
1. Add following lines to the `test.py` file.

    ```python
    import os
    from azure.core.credentials import AzureKeyCredential
    from azure.identity import DefaultAzureCredential
    from azure.ai.textanalytics import TextAnalyticsClient
    ```

1. Set endpoint and subscription key.

    ```python
    service_endpoint = os.environ["CONTAINER_ENDPOINT"]
    subscription_key = os.environ["COGNITIVE_SERVICE_KEY"]
    ```

1. Initiate the client.

    ```python
    credential = AzureKeyCredential(subscription_key)
    text_analytics_client = TextAnalyticsClient(service_endpoint, credential)
    client = text_analytics_client
    ```

1. Run language detection example with two documents, one in English and one in Spanish.

    ```python
    try:
        documents = ["The patient has fever, fatigue, and loss of appetite.",
                     "La paciente tiene fiebre y le duele la garganta"]
        response = client.detect_language(documents = documents, country_hint = 'us')

        for document_response in response:
            print("Language used: ", document_response.primary_language.name)

    except Exception as err:
        print("Encountered exception. {}".format(err))
    ```

1. Detected languages are printed, one per document submitted.

    ```bash
    Language used:  English
    Language used:  Spanish
    ```

## C#

Let’s run a sample application that consumes from our language detection container:


1. In the folder create file `proj.csproj` with following content:

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
        </ItemGroup>

    </Project>
    ```

1. Create file `test.cs`.

1. In the file import required libraries.

    ```csharp
    using System;
    using static System.Environment;
    using System.Collections.Generic;
    using Azure;
    using Azure.AI.TextAnalytics;
    ```

1. Set endpoint and subscription key.

    ```csharp
    var serviceEndpoint = GetEnvironmentVariable("CONTAINER_ENDPOINT");
    var subscriptionKey = GetEnvironmentVariable("COGNITIVE_SERVICE_KEY");
    ```

1. Initiate client.

    ```csharp
    AzureKeyCredential credentials = new AzureKeyCredential(subscriptionKey);
    var client = new TextAnalyticsClient(new Uri(serviceEndpoint), credentials);
    ```

1. Run language detection example with two documents, one in English and one in Spanish.

    ```csharp
    var documents = new List<DetectLanguageInput>
    {
        new DetectLanguageInput("1", "The patient has fever, fatigue, and loss of appetite."),
        new DetectLanguageInput("2", "La paciente tiene fiebre y le duele la garganta.")
    };

    DetectLanguageResultCollection response = client.DetectLanguageBatch(documents);
    foreach (DetectLanguageResult result in response)
    {
        Console.WriteLine($"Language used: {result.PrimaryLanguage.Name}");
    }
    ```

1. Execute project by running following commands:

    ```cmd
    dotnet build
    dotnet run
    ```

1. Detected languages are printed, one per document submitted.

    ```bash
    Language used: English
    Language used: Spanish
    ```


## Cleanup

You have completed all the exercises, but don’t forget to clean up your resources.

If you are not using the resource group for other services, you can remove everything in it by running:

```azurecli
az group delete --name <resource-group> --yes --no-wait
```

Alternatively, you could remove individual services with the following commands:

1. Azure Kubernetes Service

    ```azurecli
    az aks delete --name <aks-name> --resource-group <resource-group>
    ```

1. Azure Container Registry

    ```azurecli
    az acr delete --name <acr-name>
    ```

1. Azure Text Analytics Service

    ```azurecli
    az cognitiveservices account delete --resource-group <resource-group> --name <service-name>
    ```
