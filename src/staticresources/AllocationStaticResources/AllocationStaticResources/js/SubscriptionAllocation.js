function subscriptionAllocationData(projId, subscriptionId){

   console.log('subscriptionId =>' + subscriptionId);
       var subscriptionAllocationData =new kendo.data.DataSource({
            autosync:true,
            transport:{
              read: function(options){
                       AssetSubscriptionAllocationNewController.getSubscriptionAllocationData(projId, subscriptionId,
                          function(result,event)
                              {
                                  if (event.status) {
                                      if(result != null && result.length > 1){
                                           options.success(JSON.parse(result));
                                      console.log('results =>' + JSON.stringify(result));
                                      }else{
                                           options.success('');
                                      }
                                  } else if (event.type === 'exception') {

                                  } else {

                                  }
                              },
                              {escape: false}
                       );
              },
              update: function(options){
                   console.log('update options =>' + JSON.stringify(options.data));
                   AssetSubscriptionAllocationNewController.UpsertAssetSubscriptionAllocation(
                        'Subscription',
                        JSON.stringify(options.data),
                        function(result,event){
                               if (event.status) {
                                  var returnResult = JSON.parse(result);
                                  if(returnResult.result != 'Failed'){
                                     options.success();
                                     hideError();
                                  }else{
                                      displayError(returnResult.message);
                                  }
                                }else{
                                  displayError(event.message);
                                }
                            },
                            {escape: false}
                    );
                },
                create: function(options){
                    $('#loading').modal({
                         backdrop: 'static',
                         keyboard: false
                    });
                    $('#loading').modal('show');
                    console.log('options =>' + JSON.stringify(options.data));
                    if(options.data.ProjectNumber == null || options.data.ProjectNumber == '' || options.data.Subscription == null || options.data.Subscription == ''){
                        $('#loading').modal('hide');
                         if(currentObjectType == 'Project')
                                displayError('Please Select an Subscription before save.');
                         else if(currentObjectType == 'Subscription')
                                 displayError('Please Select a Project before save.');
                    }else{
                          AssetSubscriptionAllocationNewController.UpsertAssetSubscriptionAllocation(
                                   'Subscription',
                                   JSON.stringify(options.data),
                                   function(result,event){
                                       if (event.status) {
                                          var returnResult = JSON.parse(result);
                                          if(returnResult.result != 'Failed'){
                                               options.success();
                                                $('#loading').modal('hide');
                                                getSObjType();
                                               hideError();
                                            }else{
                                                 $('#loading').modal('hide');
                                            displayError(returnResult.message);
                                          }
                                       }else{

                                           $('#loading').modal('hide');
                                           displayError(event.message);
                                       }
                                      },
                                      {escape: false}
                              );
                          }

                },
                destroy: function(options){
                     options.success();
                }
            },
            schema:{
                model: {
                    id: "SubscriptionAllocationId",
                    fields: {
                        "Subscription": {from:"Subscription", type: "string", editable:false},
                        "SubscriptionAllocationId": { from: "SubscriptionAllocationId", type: "string",editable:false },
                        "SubscriptionName" : {from:"SubscriptionName", type:"string",editable:false },
                        "SubscriptionAllocationName" : {from:"SubscriptionAllocationName", type:"string",editable:false},
                        "Product": { from: "Product", type: "string",editable:false },
                        "ProductName": { from: "ProductName", type: "string",editable:false },
                        "ProjectNumber":{from:"ProjectNumber",type:"string",editable:false},
                        "ProjectName":{from:"ProjectName",type:"string", editable:false},
                        "ProjectPhase" : {from:"ProjectPhase", type: "string", editable:false},
                        "AllocatedQuantity":{from: "AllocatedQuantity", type:"number", editable: true, nullable: true},
                        "BudgtedHours":{from: "BudgtedHours", type:"number"},
                        "Quantity":{from: "Quantity", type:"number"},
                        "AllocatedHours":{from: "AllocatedHours", type:"number", editable: true, nullable: true},
                        AllocatedPercentage:{
                            from: "AllocatedPercentage",
                            type:"number",
                            nullable: true,
                            editable:true,
                            validation : {
                                percentageValidation : function(input){
                                    if(input.val() > 100 && input.is("[name='AllocatedPercentage']")){
                                        input.attr("data-percentageValidation-msg", " Invalid Percentage");
                                        return false;
                                    }
                                return true;
                                }
                            }
                        },
                    }
                }
            },
            change : calculateSubscriptionBudgetedHours
       });

       var window = $("#window").kendoWindow({
           title: "Are you sure you want to delete this record?",
           visible: false, //the window will not appear before its .open method is called
           width: "400px",
           height: "200px",
       }).data("kendoWindow");



    $("#subscriptionAllocationList").kendoGrid({
          dataSource: subscriptionAllocationData,
          editable: "inline",
          scrollable: true,
          noRecords: true,
          edit:addDuplicateRowSubscription,
          detailInit: loadSubscriptionChildGrid,
          dataBound: gridDataboundSubscription,
          cancel : hideChildProjects,
          toolbar: [
              {
                  name: "create",
                  text: "Add New Subscription Allocation"
              }
              ],
          columns: [{
                        field:"Id",
                        hidden: true,
                        editable:false

                    },
                    {
                        field:"SubscriptionName",
                        title:"Subscription",
                        editor:nonEditorSubscription,
                        template: '#{ #<a href="/#: data.Subscription #" target="_blank" >#= data.SubscriptionName #</a># } #',
                    },
                    {
                        field:"SubscriptionAllocationName",
                        title:"Subscription Allocation",
                        editor:nonEditorSubscription,
                        template: '#{ #<a href="/#: data.SubscriptionAllocationId #" target="_blank" >#= data.SubscriptionAllocationName #</a># } #',
                    },
                    {
                        field:"ProjectName",
                        title:"Project",
                        editor:nonEditorSubscription,
                        hidden: true,

                    },
                    {
                        field:"ProductName",
                        title:"Product",
                        editor:nonEditorSubscription,
                        template: '#{ #<a href="/#: data.Product #" target="_blank" >#= data.ProductName #</a># } #',
                    },
                    {
                        field:"ProjectPhase",
                        title:"Project Phase",
                         template: '#{ #<a href="/#: data.ProjectNumber #" target="_blank" >#= data.ProjectPhase #</a># } #',
                        editor:nonEditorSubscription,
                        filterable:true
                    },
                    {
                        field:"AllocatedQuantity",
                        title:"Allocated Quantity",
                        editable:true
                    },
                    {
                        field:"AllocatedPercentage",
                        title:"Allocated Percentage",
                        editable:true
                    },
                    {
                        field:"AllocatedHours",
                        title:"Allocated Hours",
                        editable:true
                    },
                    {   title:"Action",
                        command: ["edit",
                        {name: "Delete",
                         click: function(e){  //add a click event listener on the delete button
                                 e.preventDefault(); //prevent page scroll reset
                                 var tr = $(e.target).closest("tr"); //get the row for deletion
                                 var data = this.dataItem(tr); //get the row data so it can be referred later
                                 window.content(windowTemplate(data)); //send the row data object to the template and render it
                                 window.center().open();
                                 $("#yesButton").click(function(){
                                       var grid = $("#subscriptionAllocationList").data("kendoGrid");
                                       window.close();
                                       $('#loading').modal({
                                            backdrop: 'static',
                                            keyboard: false
                                       });
                                       $('#loading').modal('show');
                                       AssetSubscriptionAllocationNewController.DeleteAllocation(
                                           data.SubscriptionAllocationId,
                                           'Subscription',
                                           function(result,event){
                                               if (event.status) {
                                                  var returnResult = result;
                                                  if(result != 'Failed'){
                                                       grid.dataSource.remove(data);
                                                       $('#loading').modal('hide');
                                                    }else{
                                                    $('#loading').modal('hide');
                                                    displayError('Delete Unsuccessful.');

                                                  }
                                               }else{
                                                   displayError(event.message);
                                               }
                                           },
                                           {escape: false}
                                       );

                                 });
                                 $("#noButton").click(function(){
                                        window.close();
                                 });
                         }
                        }]
                    }
                ]
            });
       }

function addDuplicateRowSubscription(e){
            var subscriptionGrid = $("#subscriptionAllocationList").data("kendoGrid");;
            var dataItems = subscriptionGrid.dataItems();
            if(e.model.isNew() && !e.model.dirty ){
                if(currentObjectType == 'Subscription'){
                    e.model.Subscription = Subscription.Id;
                    e.model.SubscriptionName = Subscription.Name;
                    var firstCell = e.container.contents()[2];
                    $('<a href="/' +  e.model.Subscription + '" target="_blank">' + e.model.SubscriptionName +'</a>').appendTo(firstCell);
                    var projectCell = e.container.contents()[4];
                    $('<a style="color:blue;cursor:pointer;" onClick="loadSubscriptionDetail(this);">Select Projects </a>').appendTo(projectCell);
                      e.model.Quantity = Subscription.Quantity__c;
                    e.model.BudgtedHours = Subscription.Budgeted_Hours__c;
                    calculateRemainingSubscriptionAllocation(e.model, e.container);
                }else if(currentObjectType == 'Project'){
                    e.model.ProjectNumber = Project.Id;
                    e.model.ProjectName = Project.Name;
                    e.model.ProjectPhase = Project.Project_Phase_Allocation__c;
                    var projectCell = e.container.contents()[4];
                    $('<a href="/' +  e.model.ProjectNumber + '" target="_blank">' + e.model.ProjectName +'</a>').appendTo(projectCell);
                    var phaseCell = e.container.contents()[6];
                    $('<span>' +  e.model.ProjectPhase + '</span>').appendTo(phaseCell);

                    var firstCell = e.container.contents()[2];
                    $('<a style="color:blue;cursor:pointer;" onClick="loadSubscriptionDetail(this);">Select Subscriptions </a>').appendTo(firstCell);
                }



                 var buttonCell = e.container.contents()[10];
                 $(buttonCell).find("a.k-primary").html('<span class="k-icon k-i-update"></span> Add');
            }else{
                enableSubscriptionAllocation(e.model, e.container);
            }
             $("#subscriptionAllocationList").find(".k-hierarchy-cell, .k-hierarchy-col").hide();
}

function enableSubscriptionAllocation(rowData, row){
            var allocatedHoursCell =  $(row).children().eq(9);
            if(rowData.Quantity > 1){
                var allocatedQPercentageCell =  $(row).children().eq(8);
                $(allocatedQPercentageCell).find("span.k-numerictextbox").hide();
                $(allocatedHoursCell).find("input").prop('disabled', false).removeClass("k-state-disabled");
                $(allocatedHoursCell).find("span.k-select").show();
            }else if(rowData.Quantity == 1){
                var allocatedQuantityCell =  $(row).children().eq(7);
                $(allocatedQuantityCell).find("span.k-numerictextbox").hide();
                 $(allocatedHoursCell).find("input").prop('disabled', true).addClass("k-state-disabled");
                 $(allocatedHoursCell).find("span.k-select").hide();
            }
        }

function calculateRemainingSubscriptionAllocation(rowData, row){
            var subscriptionGrid = $("#subscriptionAllocationList").data("kendoGrid");;
            var dataItems = subscriptionGrid.dataItems();
            var totalQuantity = 0,
            totalPercentage = 0;

            for(var i = 0; i < dataItems.length; i++){
                if(rowData.Quantity > 1 && dataItems[i].get("AllocatedQuantity") != null && dataItems[i].get("Subscription") ==  rowData.Subscription){
                 totalQuantity += Number(dataItems[i].get("AllocatedQuantity"));

                }else if(rowData.Quantity == 1 && dataItems[i].get("AllocatedPercentage") != null && dataItems[i].get("Subscription") ==  rowData.Subscription){
                totalPercentage += Number(dataItems[i].get("AllocatedPercentage"));
                }
            }
            var allocatedQuantityCell =  $(row).children().eq(7);
            var allocatedQPercentageCell =  $(row).children().eq(8);
            var allocatedHoursCell =  $(row).children().eq(9);
            var hours;

            if(rowData.Quantity > 1 ){
                var remainingQuantity = rowData.Quantity -  totalQuantity;
                $(allocatedQPercentageCell).find("span.k-numerictextbox").hide();
                rowData.AllocatedQuantity = remainingQuantity;
                $(allocatedQuantityCell).find("span.k-numerictextbox").show();
                $(allocatedQuantityCell).find("input").val(remainingQuantity);
                hours = rowData.BudgtedHours * (remainingQuantity / rowData.Quantity);
                $(allocatedHoursCell).find("input").prop('disabled', false).removeClass("k-state-disabled");
                $(allocatedHoursCell).find("span.k-select").show();

            }else if(rowData.Quantity == 1 ){
                var remainingPercentage = 100 -  totalPercentage;
                rowData.AllocatedPercentage = remainingPercentage;
                $(allocatedQuantityCell).find("span.k-numerictextbox").hide();
                $(allocatedQPercentageCell).find("span.k-numerictextbox").show();
                $(allocatedQPercentageCell).find("input").val(remainingPercentage);
                var hours = rowData.BudgtedHours * (remainingPercentage / 100);
                $(allocatedHoursCell).find("input").prop('disabled', true).addClass("k-state-disabled");
                $(allocatedHoursCell).find("span.k-select").hide();

            }
            rowData.AllocatedHours = hours.toFixed(2);
            $(allocatedHoursCell).find("input").val(rowData.AllocatedHours)
        }

function nonEditorSubscription(container, options) {
        container.text(options.model[options.field]);
}

function gridDataboundSubscription(e){
          // var grid = this;
          $("#subscriptionAllocationList").find(".k-hierarchy-cell, .k-hierarchy-col").hide();
      }

function calculateSubscriptionBudgetedHours(e){
    if (e.action === "itemchange" && (e.field == "AllocatedPercentage" || e.field == "AllocatedQuantity")){
            var model = e.items[0],
                budgtedHours = model.BudgtedHours,
                currentValue;
                allocatedHoursInput = $("#subscriptionAllocationList").find("tr[data-uid='" + model.uid + "'] td:eq(9)");
          if(model.AllocatedPercentage > 0 ){
              currentValue = (budgtedHours * (model.AllocatedPercentage / 100)).toFixed(2);
              $(allocatedHoursInput).find("input").val(currentValue).prop('disabled', true).addClass("k-state-disabled");
               $(allocatedHoursInput).find("span.k-select").hide();
          }else if(model.AllocatedQuantity > 0 ){
              currentValue = (budgtedHours * (model.AllocatedQuantity / model.Quantity)).toFixed(2);
              $(allocatedHoursInput).find("input").val(currentValue).prop('disabled', false).removeClass("k-state-disabled");
              $(allocatedHoursInput).find("span.k-select").show();
          }
          model.AllocatedHours = currentValue;
    }
}

 function loadSubscriptionDetail(obj){
       var row = $(obj).parent().parent();
       var link = $(row).find("td.k-hierarchy-cell .k-icon");

       link.click();
       $(row).find("tr.k-detail-row").show();
       $(row).next().find(".k-hierarchy-cell").hide();
   }

function loadSubscriptionChildGrid(e){
        if(currentObjectType === 'Subscription'){
           detailSubscriptionProjects(e);
        } else if(currentObjectType === 'Project'){
            detailSubscription(e);
        }
    }

function detailSubscriptionProjects(e) {
        $("<div id='detailSubscriptionTable'/>").appendTo(e.detailCell).kendoGrid({
        dataSource: {
            autosync:true,
            transport: {
                read: function(options){
                     AssetSubscriptionAllocationNewController.PhaseProjectDetailsSubscription(
                        e.data.Subscription,
                        function(result,event){
                          if (event.status) {
                              if(result.length > 1){
                                   options.success(JSON.parse(result));
                                   console.log('PhaseProjectDetails =>' + JSON.stringify(result));
                              }
                          }
                        },{escape: false}
                     );
                },
            },
            schema:{
                model: {
                    id: "ProjectId",
                    fields: {
                        ProjectId: { from: "Id"},
                        ProjectNumber: {from:"Name", type: "string"},
                        Summary : {from:"Summary__c", type:"string"},
                        Status : {from:"ProjectStatus__c", type:"string"}
                    }
                }
            }
        },
        scrollable: false,
        sortable: true,
        columns: [
            { command: { text: "Select", click : selectSubscriptionProject}, title: "Action", width: "60px" },
            { field: "ProjectNumber", width: "110px" },
            { field: "Summary", title:"Project Summary", width: "200px" },
            { field: "Status", title:"Project Status", width: "110px" }
        ]
    });
    }

function selectSubscriptionProject(e){
    var dataItem = this.dataItem($(e.currentTarget).closest("tr"));

    var detailGrid = this.wrapper;
    var parentRow = detailGrid.closest("tr.k-detail-row").prev("tr");
    var grid = $("#subscriptionAllocationList").data("kendoGrid");
    var rowData = grid.dataItem(parentRow);
    if(rowData){
      rowData.ProjectNumber = dataItem.ProjectId;
      rowData.ProjectName = dataItem.ProjectNumber;
      rowData.ProjectPhase = dataItem.ProjectNumber + ' - ' + dataItem.Summary;
      //grid.dataSource.sync();

      var projectCell = $(parentRow).children().eq(4);
      var htmlContentProject = $('<a style="color:blue;cursor:pointer;" onClick="loadSubscriptionDetail(this);">' + dataItem.ProjectNumber +'</a>');
      $(projectCell).html(htmlContentProject);
      var projectPhaseCell = $(parentRow).children().eq(6);
      var htmlProjectPhase = $('<span> ' + rowData.ProjectPhase +'</span>');
      $(projectPhaseCell).html(htmlProjectPhase);
    }
    grid.collapseRow(parentRow);

  }

function detailSubscription(e) {
            $("<div id='detailSubscriptionTable'/>").appendTo(e.detailCell).kendoGrid({
            dataSource: {
                autosync:true,
                transport: {
                    read: function(options){
                         AssetSubscriptionAllocationNewController.AssetSubscriptionDetailsFromProjectPhase(
                            e.data.ProjectNumber,
                            'Subscription',
                            function(result,event){
                              if (event.status) {
                                  if(result){
                                       options.success(JSON.parse(result));
                                       console.log('Subscription Details =>' + JSON.stringify(result));
                                  }else{
                                      options.success('');
                                  }
                              }
                            },{escape: false}
                         );
                    },
                },
                schema:{
                    model: {
                        id: "SubscriptionId",
                        fields: {
                            SubscriptionId: { from: "Id"},
                            SubscriptionName: {from:"Name", type: "string"},
                            Product: {from:"Product_Name__c", type: "string"},
                            RemainingPercentage : {from:"Remaning_Percentage__c", type:"string"},
                            RemainingQuantity : {from:"RemainingQuantity__c", type:"string"},
                            RemainingHours : {from:"Remaining_Hours__c", type:"string"},
                            Quantity:{from:'Quantity__c', type:"number"},
                            BudgtedHours:{from:'Budgeted_Hours__c', type:"number"}
                        }
                    }
                }
            },
            scrollable: false,
            sortable: true,
            noRecords: true,
            columns: [
                 {command: { text: "Select", click : selectSubscription}, title: "Action", width: "60px" },
                { field: "SubscriptionName", title:"Subscription", width: "110px" },
                { field: "Product", title:"Product", width: "110px" },
                { field: "RemainingPercentage", title:"Remaining Percentage", width: "200px" },
                { field: "RemainingQuantity", title:"Remaining Quantity", width: "110px" },
                { field: "RemainingHours", title:"Remaining Hours", width: "110px" }
            ]
            });
        }

function selectSubscription(e){
        var dataItem = this.dataItem($(e.currentTarget).closest("tr"));
        var detailGrid = this.wrapper;
        var parentRow = detailGrid.closest("tr.k-detail-row").prev("tr");
        var grid = $("#subscriptionAllocationList").data("kendoGrid");
        var rowData = grid.dataItem(parentRow);
        if(rowData){
            rowData.Subscription = dataItem.SubscriptionId;
            rowData.SubscriptionName = dataItem.SubscriptionName;
            rowData.AllocatedPercentage = null;
            rowData.AllocatedQuantity = null;
            rowData.AllocatedHours = 0;
            rowData.Quantity = dataItem.Quantity;
            rowData.BudgtedHours = dataItem.BudgtedHours;
            rowData.ProductName = dataItem.Product;
            var subscriptionCell = $(parentRow).children().eq(2);
            var htmlContentProject = $('<a style="color:blue;cursor:pointer;" onClick="loadSubscriptionDetail(this);">' + dataItem.SubscriptionName +'</a>');
            $(subscriptionCell).html(htmlContentProject);
            var ProductCell = $(parentRow).children().eq(5);
            $('<a href="#" target="_blank">' + rowData.ProductName +'</a>').appendTo(ProductCell);
            calculateRemainingSubscriptionAllocation(rowData, parentRow);
        }
        grid.collapseRow(parentRow);
    }























