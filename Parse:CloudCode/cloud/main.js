
Parse.Cloud.afterSave("ZSSMessage", function(request) {
    var receiver = request.object.get("receiver");
    var sender = request.object.get("sender");
    
    var pushQuery = new Parse.Query(Parse.Installation);
    pushQuery.equalTo("user", request.object.get("receiver"));
    
    receiver.fetch({ 
        success: function(receiver) {
            
            sender.fetch({ 
                success: function(sender) {
                    if (request.object.get("viewed") == true){

                        //Do nothing
                    }else if(request.object.get("dateViewed")) {
                    	//Do nothing
                    }else{
                        Parse.Push.send({
                        where: pushQuery,
                        data:{
                            alert: "New Shak from " + sender.get("username"),
                            badge: "Increment",
                            sound: "Sup.aiff",
                            username: sender,
                            type : "message"
                            }
                        });  
                    }




                },
                error: function(sender, error) {
                // The object was not refreshed successfully.
                // error is a Parse.Error with an error code and message.
                }
        
            });   
        },
        error: function(receiver, error) {
        // The object was not refreshed successfully.
        // error is a Parse.Error with an error code and message.
        }
    });
});

Parse.Cloud.afterSave("ZSSFriendRequest", function(request) {
    var receiver = request.object.get("receiver");
    var sender = request.object.get("sender");
    
    receiver.fetch({ 
        success: function(receiver) {
            
            sender.fetch({ 
                success: function(sender) {
                    
                    if (request.object.get("confirmed")){
        //Friend Request has been confirmed
                        
                        var pushQuery = new Parse.Query(Parse.Installation);
                        pushQuery.equalTo("user", request.object.get("sender"));
                        
                        Parse.Push.send({
                        where: pushQuery,
                        data:{
                            alert:  receiver.get("username") + " added you!",
                            sound: "Sup.aiff",
                            username: receiver
                            }
                        });  

                    }else{
        //Friend Request has been sent
                
                        var pushQuery = new Parse.Query(Parse.Installation);
                        pushQuery.equalTo("user", request.object.get("receiver"));
                
                        Parse.Push.send({
                        where: pushQuery,
                        data:{
                            alert:  sender.get("username") + " wants to add you!",
                            sound: "Sup.aiff",
                            username: sender,
                            type: "FriendRequest"
                            }
                        });  
                    
    
                    }
        
        
                },
                error: function(sender, error) {
                // The object was not refreshed successfully.
                // error is a Parse.Error with an error code and message.
                }
        
            });   
        },
        error: function(receiver, error) {
        // The object was not refreshed successfully.
        // error is a Parse.Error with an error code and message.
        }
    });
});



