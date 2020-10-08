# Exercise - Working with Intents

You will now create intents for each of the items in the bullet list above.

> [!NOTE]
> There is one intent already present named **None**. Random utterances that don't map to any of your intents can be mapped to this intent. The None intent is a required intent and can't be deleted or renamed. Fill it with utterances that are outside of your domain.

## Create intents in LU portal

1. Ensure that you are on the **Intents** page in the LU portal.
1. Select **+ Create**.
1. Because our scenario for this application is to integrate with a fictional bot, you'll provide examples of utterances that users might say when greeting the bot initially.  You will create an **Intent** to handle greetings.
1. Name the first intent **Greeting**, and then select **Done**.
1. Next create an **Intent** to handle the task of searching for pictures.
1. Select **+ Create** and create another intent named **SearchPic**, then select **Done**.
1. Add two more intents **SharePic** and **OrderPic**.

## Create intents in code

For this exercise, you will add code to the project you started in unit 2, creating the LU app.  This code uses a list to store the intents you want to add to the LU app.  The code will iterate over the items in the list and asynchronously add them to the LU app.  To expand the app with more intents, you simply add them to the list.

### Using Python

1. You will create a new function in your Python code to add intents to the LU app.
1. In your existing Python code from unit 2, add this function below the create_app() function.

   ```python
   def add_intents(app_id, app_version):
       intents = ["Greeting", "SearchPics", "OrderPic", "SharePic"]
       for intent in intents:
           intentId = client.model.add_intent(app_id, app_version, intent)
           print("Intent {} {} added.".format(intent, intentId))
   ```

1. Modify the create_app() function and add this line of code before the existing return statement.

   ```python
   add_intents(app_id, app_version)
   ```

1. You will expand on this code in later units.

### Using C-Sharp

1. Create a new method in the **Program.cs** class to handle adding the intents.  The following code provides the method content.

   ```csharp
   async static Task AddIntents(LUISAuthoringClient client, ApplicationInfo app_info)
           {
               List<String> intents = new List<String>();
               intents.Add("Greeting");
               intents.Add("SearchPic");
               intents.Add("OrderPic");
               intents.Add("SharePic");
   
               foreach (string intent in intents)
               {
                   await client.Model.AddIntentAsync(app_info.ID, app_info.Version, new ModelCreateObject()
                   {
                       Name = intent
                   });
                   Console.WriteLine("Created intent {0}", intent);
               }
           }
   ```   

1. The code creates an asynchronous method called AddIntents.  The method requires a LU client and the application info (ID and name).
1. A generic list is created that holds four intents that will be added to the LU app.
1. Using a foreach loop, the code iterates over the list, takes each string value, and then calls the AddIntentAsync() method from the LU authoring API.
1. You will also need to call this method from within Main() so add this line of code just before the closing brace of Main().

   ```csharp
   await AddIntents(client, appInfo);
   ```

1. You will expand on this code in later units.
