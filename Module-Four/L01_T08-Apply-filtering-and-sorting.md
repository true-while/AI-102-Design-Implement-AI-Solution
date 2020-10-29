# Exercise - Filter and sort Margie's Travel results

You can apply filtering and sorting to the Margie's Travel search results by submitting a new query that includes a filter and sort order. 
Select your preferred language below, and then follow the steps below to filter and sort results.

### Using Python

1. In the **Python/search-client** folder, open the **app&#46;py** code file containing the code for the Flask web application.
2. Examine the code in the **filter** function (for the **/filter** route), and review the **searchParams** definition. This includes some of the same parameters as the basic search function you examined previously, with the following differences:
    - **queryType**: This parameter has been changed to **Full**, indicating that Lucene syntax for filtering expressions will be used.
    - **$filter**: This parameter has been used to specify a filtering expression. In this case, the filter is based on the **author** facet value selected by the user in the user interface, but you could specify any filtering expression that applies comparative logic to any filterable field.
    - **$orderBy**: This parameter specifies a sort order for the results. The default sort order is based on a built-in field named **@search.score**, which uses a *scoring profile* to calculate a relevance score for each result based on factors like the frequency of search term occurrence, the presence of search terms in the document name, and so on  (you can create custom scoring profiles as alternatives to the default one). You can specify the scoring profile sort order explicitly by using the built-in **search.score()** function, or you can specify an alternative sort order based on user selection. In this case, the user can choose to sort the results into ascending order by file name, descending order by size, or descending order by last modified date.
3. In the **Terminal** pane, select the bash terminal for the **search-client** folder. If you have closed this terminal, right-click (Ctrl+click if using a Mac) the **Python/search-client** folder and select **Open in Integrated Terminal**.
4. In the terminal for the **search-client** folder, enter the following command:
    ```bash
    flask run
    ```
5. Follow the link for the `https://127.0.0.1:5000/` address to open the web site in a new browser tab. Then in the Margie's Travel website, enter **"San Francisco"** into the search box and click **Search**.
6. When the results are displayed, select the **Reviewer** filter and the **Largest file size** sort option, and click **Refine Results**.
7. Observe that the results are filtered to include only reviews, and sorted into descending order of file size.
8. Close the browser tab containing the Margie's Travel web site and return to Visual Studio Code. Then in the Python terminal for the **search-client** folder (where the flask application is running), enter Ctrl+C to stop the app.

### Using Csharp

1. In the **C-Sharp/search-client/Pages** folder, open the **Index.cshtml.cs** code file containing the code for the web application's main page.
2. Examine the code in the **OnGet** function, noting that the parameters that can be submitted to the page include **sort** and **facet**. 
    - The **sort** parameter defines a sort order that is applied to the query results in the **OrderBy** search parameter. The default sort order is based on a built in field named **@search.score**, which uses a *scoring profile* to calculate a relevance score for each result based on factors like the frequency of search term occurrence, the presence of search terms in the document name, and so on  (you can create custom scoring profiles as alternatives to the default one). You can specify the scoring profile sort order explicitly by using the built-in **search.score()** function, or you can specify an alternative sort order based on user selection. In this case, the user can choose to sort the results into ascending order by file name, descending order by size, or descending order by last modified date.
    - The **facet** parameter contains the value of the faceted **author** field that the user has selected from the original results. Its value is used to specify a filtering expression in the **Filter** search parameter. In this case, the filter is based on the **author** facet value selected by the user in the user interface, but you could specify any filtering expression that applies comparative logic to any filterable field.
3. In the **Terminal** pane, select the bash terminal for the **search-client** folder. If you have closed this terminal, right-click (Ctrl+click if using a Mac) the **C-Sharp/search-client** folder and select **Open in Integrated Terminal**.
4. In the terminal for the **search-client** folder, enter the following command:
    ```bash
    dotnet run
    ```
5. Follow the link for the `https://localhost:5000/` address to open the web site in a new browser tab. Then in the Margie's Travel website, enter **"San Francisco"** into the search box and click **Search**.
6. When the results are displayed, select the **Reviewer** filter and the **Largest file size** sort option, and click **Refine Results**.
7. Observe that the results are filtered to include only reviews, and sorted into descending order of file size.
8. Close the browser tab containing the Margie's Travel web site and return to Visual Studio Code. Then in the terminal for the **search-client** folder (where the dotnet process is running), enter Ctrl+C to stop the app.


> [!NOTE]
> For more information about using filters, see [Filters in Azure Cognitive Search](https://docs.microsoft.com/azure/search/search-filters). For information about working with results, including sorting and hit highlighting, see [How to work with search results in Azure Cognitive Search](https://docs.microsoft.com/azure/search/search-pagination-page-layout).
