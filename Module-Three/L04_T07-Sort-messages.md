Let's look at our solution architecture again.

![Conceptual diagram of a feedback sorting architecture.](media/proposed-solution.PNG)

As you can see on the right side of this diagram, we want to send messages to three queues. So, we'll define those connections as output bindings in our function. We could create those bindings through the **Output binding** UI. However, to save time, we'll edit the config file directly.

## Add output bindings to function.json

1. Select our function in the Function Apps portal.

1. Expand the **View files** menu on the right of the screen.

1. Under the **View files** tab, select **function.json** to open the config file in the editor.

1. Replace the entire contents of **function.json** with the following JSON and select **Save**.

```json
{
    "bindings": [
      {
        "name": "myQueueItem",
        "type": "queueTrigger",
        "direction": "in",
        "queueName": "new-feedback-q",
        "connection": "AzureWebJobsStorage"
      },
      {
        "type": "queue",
        "name": "positiveFeedbackQueueItem",
        "queueName": "positive-feedback-q",
        "connection": "AzureWebJobsStorage",
        "direction": "out"
      },
      {
        "type": "queue",
        "name": "neutralFeedbackQueueItem",
        "queueName": "neutral-feedback-q",
        "connection": "AzureWebJobsStorage",
        "direction": "out"
      },
      {
        "type": "queue",
        "name": "negativeFeedbackQueueItem",
        "queueName": "negative-feedback-q",
        "connection": "AzureWebJobsStorage",
        "direction": "out"
      }
    ],
    "disabled": false
  }

```

We've added three new bindings to the config.

- Each new binding is of type `queue`. These bindings are for the three queues that we'll populate with our feedback messages once we know the sentiment of the feedback.
- Each binding has a direction defined as `out`, since we'll post messages to these queues.
- Each binding uses the same connection to our storage account.
- Each binding has a unique `queueName` and `name`.

Posting a message to a queue is as easy as saying, for example,  `context.bindings.negativeFeedbackQueueItem = "<message>"`.

## Update the function implementation to sort feedback into queues based on sentiment score

The goal of our feedback sorter is to sort feedback into three buckets: positive, neutral, and negative. So far, we have our input queue, our code to call the Text Analytics API, and we've defined our output queues. In this section, we'll add the logic to move messages into those queues based on sentiment.

1. Navigate to our function and open `index.js` in the code editor again.

1. Replace the implementation with the following code.

```javascript
module.exports = function (context, myQueueItem) {
    context.log('Processing queue message', myQueueItem);

    let https = require ('https');

    // Replace the accessKey string value with your valid access key.
    let accessKey = '<YOUR ACCESS CODE HERE>';

    // Replace [region], including square brackets, in the uri variable below. 
    // You must use the same region in your REST API call as you used to obtain your access keys.
    // For example, if you obtained your access keys from the northeurope region, replace 
    // "westus" in the URI below with "northeurope".
    let uri = '[region].api.cognitive.microsoft.com';
    let path = '/text/analytics/v2.0/sentiment';

    let response_handler = function (response) {
        let body = '';

        response.on ('data', function (chunk) {
            body += chunk;
        });

        response.on ('end', function () {
            let body_ = JSON.parse (body);

            // Even though we send and receive a documents array from the Text Analytics API, 
            // we only ever pass one document in the array.
            if (body_.documents && body_.documents.length == 1) {
                let score = body_.documents[0].score;
                
                // Create a message that contains the original message we received and 
                // the sentiment score returned by Text Analytics API.
                let messageWithScore = JSON.stringify({ 
                    originalMessage: myQueueItem,
                    score: score
                });

                // Place message into appropriate output queue based on sentiment score.
                if (score > 0.8) {
                    context.log ("Positive message arrived");
                    context.bindings.positiveFeedbackQueueItem = messageWithScore;
                } else if (score < 0.3) {
                    context.log ("Negative message arrived");
                    context.bindings.negativeFeedbackQueueItem = messageWithScore;
                } else {
                    context.log ("Neutral message arrived");
                    context.bindings.neutralFeedbackQueueItem = messageWithScore;
                }
            } 
            let body__ = JSON.stringify (body_, null, '  ');
            context.log (body__);
            context.done();
            return;
        });

        response.on ('error', function (e) {
            context.log ('Error: ' + e.message);
            context.done();
            return;
        });    
    };

    let get_sentiments = function (documents) {
        let body = JSON.stringify (documents);

        let request_params = {
            method : 'POST',
            hostname : uri,
            path : path,
            headers : {
                'Ocp-Apim-Subscription-Key' : accessKey,
            }
        };

        let req = https.request (request_params, response_handler);
        req.write (body);
        req.end ();
        
    }

    // Create a documents array with one entry. 
    let documents = { 'documents': [
        { 
            'id': '1', 
            'language': 'en', 
            'text': myQueueItem 
        },
    ]};

    get_sentiments (documents);
        
};
```

We've added some code to our implementation. The code parses the response from the Text Analytics API cognitive service. Based on the sentiment score, the message is forwarded to one of our three output queues. The code to post the message is just setting the correct binding parameter.

## Try it out

To test the updated implementation, we'll head back to the Storage Explorer.

1. Navigate to your resource group in the **Resource Groups** section of the portal.

1. Select the resource group used in this lesson.

1. In the **Resource group** panel that opens, locate the Storage Account entry and select it.
    ![Screenshot of storage account selected in the Resource Group window.](media/select-storage-account.png)

1. Select **Storage Explorer (preview)** from the left menu of the Storage Account main window. This action opens the Azure Storage Explorer inside the portal.

    ![Screenshot of Storage Explorer showing our storage account, with one queue currently.](media/storage-explorer-menu-inputq.png)

    We have one queue listed under the **Queues** collection. This queue is **new-feedback-q**, the input queue we defined in the preceding test section of the module.        

1. Select **new-feedback-q** in the left-hand menu to see the data explorer for this queue. As expected, the queue had no data. Let's add a message to the queue using the **Add Message** command at the top of the window.

1. In the **Add Message** dialog, enter "I'm having fun with this exercise!" into the **Message text** field, and select **OK** at the bottom of the dialog.

1. The message is displayed in the data window for **new-feedback-q**. After a few seconds, click **Refresh** at the top of the data view to refresh the view of the queue. Observe that the message disappears after a while. So, where did it go?

1. Right-click on the **QUEUES** collection in the left-hand menu. Observe that a *new* queue has appeared.
    ![Screenshot of Storage Explorer showing that a new queue has been created in the collection. The queue has one message.](media/sa-new-output-q.png)

    The queue **positive-feedback-queue** was automatically created when a message was posted to it for the first time. With Azure Functions queue output bindings, you don't have to manually create the output queue before posting to it! Now that we see an incoming message has been sorted by our function into **positive-feedback-queue**, let's see where the following messages land.    

1. Using the same steps as above, add the following messages to **new-feedback-q**.

    - "I hate broccoli!"
    - "Microsoft is a company"

1. Click **Refresh** until **new-feedback-q** is empty once again. This process might take a few moments and require several refreshes.

1. Right-click on the **QUEUES** collection and observe two more queues appearing. The queues are named **neutral-feedback-queue** and **negative-feedback-queue**. This might take a few seconds, so continue refreshing the **QUEUES** collection until new queues appear. When complete, your queue list should look like the following.

    ![Screenshot of Storage Explorer menu showing four queues in the QUEUES collection.](media/sa-final-q-list.png)

1. Click on each queue in the list to see whether they have messages. If you added the suggested messages, you should see one in **positive-feedback-queue**, **neutral-feedback-queue**, and **negative-feedback-queue**.

Congratulations! We now have a working feedback sorter! As messages arrive in the input queue, our function uses the Text Analytics API service to get a sentiment score. Based on that score, the function forwards the messages to the appropriate queue. While it seems like the function processes only one queue item at a time, the Azure Functions runtime will actually read batches of queue items and spin up other instances of our function to process them in parallel.
