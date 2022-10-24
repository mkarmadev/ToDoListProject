({
    setColumns : function(component) {

        component.set("v.columns", [
			{label:"Person", fieldName:"personFullName", type:"text"},
			{label:"Total projects", fieldName:"numberOfProjects", type:"text"}
		]);

    },

    setData : function(component) {

        let action = component.get("c.getBestPersonsWhoFinishedInTime");
        action.setParams({
            "personsNumber": 5
        });
		
        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") {
				
				let records = response.getReturnValue();

				component.set("v.persons", records);

            }else if (state === "ERROR") {
                
                let errors = response.getError();
                if(errors){
                    if(errors[0] && errors[0].message){
                        console.log("Error message: " + errors[0].message);
                    }
                }
            }
            else {
                console.log("Failed with state: " + state);
            }
        });

        $A.enqueueAction(action);
    }

})


