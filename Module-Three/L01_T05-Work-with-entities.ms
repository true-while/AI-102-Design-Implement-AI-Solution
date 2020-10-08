# Exercise - Working with Entities

## Create entities in the LUIS portal

1. Ensure you are signed in to your LU app and on the **Build** tab.

1. In the left column, select **Entities**, and then select **+ Create**.

1. Name the entity **facet** (to represent one way to identify an image).

1. Select **Machine learned** for **Type**. Then select **Create**.

    ![Adding an entity named facet, of type Machine learned](media/select-facet.png)

## Add entities with code

In this exercise, you will use code to add the single **facet** entity to the application. You can use the code sample here to add multiple entities if you want.  The code will be the same as for a single entity.

### Using Python

1. Create a function to add the entity to the LUIS app.

   ```python
   def add_entities(app_id, app_version):
   
       facetEntityId = client.model.add_entity(app_id, app_version, name="facet")
       print("facetEntityId {} added.".format(facetEntityId))
   ```

1. Modify the create_app() function by adding the following line of code under the add_intents() function.

   ```python
   add_entities(app_id, app_version)
   ```

1. You will expand on this code in later units.

### Using C-Sharp

1. Create a new method in your Program.cs class to add an entity to the LUIS application.

   ```csharp
   // Create entity objects
   async static Task AddEntities(LUISAuthoringClient client, ApplicationInfo app_info)
   {
       // Add machine learned entity
       var facetEntityId = await client.Model.AddEntityAsync(app_info.ID, app_info.Version, new ModelCreateObject()
       {
           Name = "facet"
       });
   
       Console.WriteLine("Created entity facet");
   }
   ```

1. Modify Main() to add a call to this method immediately after the call to AddIntents().

   ```csharp
   await AddEntities(client, appInfo);
   ```

1. You will expand on this code in later units.
