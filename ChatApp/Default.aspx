<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="ChatApp.Default" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <link href="style.css" rel="stylesheet" />
    <link href="Content/bootstrap.min.css" rel="stylesheet" />
    <script src="firebase.js"></script>
    <script src="custom.js"></script>
    <script src="Scripts/jquery-1.9.1.js"></script>
    <script src="Scripts/bootstrap.min.js"></script>
    <script src="Scripts/angular.min.js"></script>
    <script src="Scripts/jquery.cookie.js"></script>
    <script>
        // Initialize Firebase
        var config = {
            apiKey: "AIzaSyAows_XjpM0mmSS2QQ471syfNoXOWgEwl0",
            authDomain: "chat-72e8e.firebaseapp.com",
            databaseURL: "https://chat-72e8e.firebaseio.com",
            storageBucket: "chat-72e8e.appspot.com",
            messagingSenderId: "543047894575"
        };
        firebase.initializeApp(config);
        var database = firebase.database();
        var auth = firebase.auth();
    </script>

    <title>Chat Application</title>

</head>
<body>
    <form id="form1" runat="server">
        <div class="container">
            <h1>Firebase Chat Application</h1>
            <div class="col-lg-8">
                <div class="panel panel-default">
                    <div class="panel-body">
                        <div class="comment-container">
                            <!-- This Content of Chats-->
                        </div>
                    </div>
                    <div class="panel-footer">
                        <div class="form-group">
                            <label for="comments">Please enter your comments here</label>
                            <input type="text" class="form-control" id="comments" name="comments" />
                        </div>

                        <button type="submit" id="submit-btn" name="submit-btn"
                            class="btn btn-primary">
                            Send Comments</button>

                        <button type="reset" class="btn btn-default">Clear Comment</button>

                        <button type="button" id="next-btn" class="btn btn-success">Next</button>

                        <button type="button" id="prev-btn" class="btn btn-success">Prev</button>

                    </div>
                </div>
            </div>
            <div class="col-lg-4">
                <div class="panel panel-default">
                    <div class="panel-body">
                        <div class="user-container">
                            <!-- This Content of Chats-->
                        </div>
                    </div>
                    <div class="panel-footer">
                        <div class="form-group">
                            <button type="button" id="logout-btn" class="btn btn-danger">logout</button>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </form>

    <script>

        var messagesRef = database.ref().child("messages");
        var usersRef = database.ref().child("users");
        var limitToLastNo = 10;
        var messages = [];
        var users = [];
        

        var array = window.location.search.split("?");
        var publicUsername = array[1];
        var publicKeyForDelete = null;
        
        //اسنپشات از کلیه دادها در دیتابیس را برمیگرداند
        //messagesRef.on('value', function (snapshot) {
        //    snapshot.forEach(function (snap) {
        //        $(".comment-container").prepend("<p>" + snap.val().owner + " : " + snap.val().comment + "</p>");
        //    })
        //})

        //نمایش پیغام ها
        function DisplayeMassages() {
            messages.forEach(function (message) {
                
                var delete_massage_image = publicUsername == "Admin" ? "<button type='button' id=" + message.name + " class='btn btn-default' onClick='DeleteMessage(this.id);'><img src='images/erase.png' /></button>" : "<img src='images/checked.png' />";

                var userlike = message.userLike != ""? " last liked by " + message.userLike:"";
                var message_like_button = "<button type='button' id=" + message.name + "," + message.numLike + " class='btn btn-default' onClick='LikeIt(this.id);'><img src='images/heart.png' /></button>" + " - " + message.numLike + userlike;

                $(".comment-container").prepend("<p>" + delete_massage_image + message.user + " : " + message.comment +"  "+ message_like_button + "</p>");
            })
        }
        
        function DeleteMessage(id){
            messagesRef.child(id).remove();
        }

        function LikeIt(id) {
            var ids = id.split(',')
            messagesRef.child(ids[0]).update({
                numLike: parseInt(ids[1])+1,
                userLike: publicUsername
            })
        }
        //نمایش کاربران
        function DisplayeUsers() {
            users.forEach(function (user) {
                if (user.role == "Admin")
                    userImage = "<img src='images/Admin.png' />";
                else
                    userImage = "<img src='images/user.png' />"
                $(".user-container").prepend("<p>" + userImage + " " + user.username + "</p>");
            })
        }

        //در ابتدا کلیه اسنپشات ها را برمیگرداند و بعد از آن به ازای اضافه شدن هر داده فقط آن را برمیگرداند
        messagesRef.limitToLast(limitToLastNo).on('child_added', function (snapshot) {

            var rownum = snapshot.numChildren();
            var comment = snapshot.val().comment;
            var user = snapshot.val().user;
            var numLike = snapshot.val().numLike;
            var userLike = snapshot.val().userLike;
            var key = snapshot.getKey();
            messages.push({
                user: user,
                comment: comment,
                name: key,
                numLike: numLike,
                userLike: userLike
            });
            var delete_massage_image = publicUsername == "Admin" ? "<button type='button' id=" + key + " class='btn btn-default' onClick='DeleteMessage(this.id);'><img src='images/erase.png' /></button>" : "<img src='images/checked.png' />";

            var userlike = userLike != "" ? " last liked by " + userLike : "";
            var message_like_button = "<button type='button' id=" + key + "," + numLike + " class='btn btn-default' onClick='LikeIt(this.id);'><img src='images/heart.png' /></button>" + " - " + numLike + userlike;

            $(".comment-container").prepend("<p>" + delete_massage_image + " " + user + " : " + comment + "  " + message_like_button + "</p>");
        })

        //زمانی که یک داده تغییر میکند تغییر یافته را بر میگرداند
        messagesRef.on('child_changed', function (snapshot) {

            var comment = snapshot.val().comment;
            var user = snapshot.val().user;
            var numLike = snapshot.val().numLike;
            var userLike = snapshot.val().userLike;
            var name = snapshot.getKey();

            EditMessageByName(name, comment, numLike, userLike);
            $(".comment-container").html("");
            DisplayeMassages();
        })

        //داده را بدون درنگ آپدیت می کند
        function EditMessageByName(name, newComment, numLike, userLike) {
            for (var i = 0; i < messages.length; i++) {
                if (messages[i].name == name) {
                    messages[i].comment = newComment;
                    messages[i].numLike = numLike;
                    messages[i].userLike = userLike;
                    break
                }
            }
        }

        //زمانی که یک داده حذف مشود آن را بر میگرداند
        messagesRef.on('child_removed', function (snapshot) {

            var name = snapshot.getKey();
            deleteMessageByName(name);
            $(".comment-container").html("");
            DisplayeMassages();
        })

        //داده را بدون درنگ خذف می کند
        function deleteMessageByName(name) {
            for (var i = 0; i < messages.length; i++) {
                if (messages[i].name == name) {
                    messages.splice(i, 1);
                    break
                }
            }
        }

        //زمانی که کلیک میشود پیام یوزر مورد نظر را در دیتا بیس ثبت می کند
        $("#submit-btn").bind("click", function () {

            var comment = $("#comments")
            var comment_value = $.trim(comment.val());

            messagesRef.push(
                {
                    comment: comment_value,
                    user: publicUsername,
                    numLike: "0",
                    userLike: ""

                }, function (error) {
                    if (error != null)
                        alert(error);
                });
            return false;
        }
        )

        // قابلیت صفحه بندی برای ادمین
        $("#next-btn").bind("click", function () {

            lastMessage = messages[messages.length - 1];
            var startName = lastMessage.name;
            messages = [];
            $(".comment-container").html("");

            messagesRef.startAt(null, startName).limitToLast(10).once('value', function (snapshot) {

                snapshot.forEach(function (snap) {

                    messages.push({
                        user: snap.val().user,
                        comment: snap.val().comment,
                        name: snap.getKey()
                    });
                    var delete_massage_image = publicUsername == "Admin" ? "<button type='button' id=" + message.name + " class='btn btn-default' onClick='DeleteMessage(this.id);'><img src='images/erase.png' /></button>" : "<img src='images/checked.png' />";
                    $(".comment-container").prepend("<p>"+ delete_massage_image + snap.val().user + " : " + snap.val().comment + "</p>");
                })
            })
        }
        )

        $("#prev-btn").bind("click", function () {

            lastMessage = messages[messages.length - 1];
            var startName = lastMessage.name;
            messages = [];
            $(".comment-container").html("");

            messagesRef.endAt(null, startName).limitToFirst(10).once('value', function (snapshot) {

                snapshot.forEach(function (snap) {

                    messages.push({
                        user: snap.val().user,
                        comment: snap.val().comment,
                        name: snap.getKey()
                    });
                    var delete_massage_image = publicUsername == "Admin" ? "<button type='button' id=" + message.name + " class='btn btn-default' onClick='DeleteMessage(this.id);'><img src='images/erase.png' /></button>" : "<img src='images/checked.png' />";
                    $(".comment-container").prepend("<p>" + delete_massage_image + snap.val().user + " : " + snap.val().comment + "</p>");
                })
            })
        }
        )

        //قابیت نمایش کاربران حاضر در چت
        usersRef.on('child_added', function (snapshot) {
            var username = snapshot.val().username;
            var email = snapshot.val().email;
            var key = snapshot.getKey();
            var role = snapshot.val().role;

            if (role == "Admin")
                userImage = "<img src='images/Admin.png' />";
            else
                userImage = "<img src='images/user.png' />"

            users.push({
                username: username,
                email: email,
                name: key
            });
            
            $(".user-container").prepend("<p>" + userImage + " " + username + "</p>");
        })

        //خارج شدن از محیط چت
        $("#logout-btn").bind("click", function () {

            publicKeyForDelete = GetKeyByUserName(publicUsername);
            usersRef.child(publicKeyForDelete).remove();

            return false;
        }
        )

        function GetKeyByUserName(username) {
            var key = null;
            for (var i = 0; i < users.length; i++) {
                if (users[i].username == username) {
                    key = users[i].name;
                    break
                }
            }
            return key;
        }

        //زمانی که یک کاربر از چت خارج میشود آن را بر میگرداند
        usersRef.on('child_removed', function (snapshot) {

            $(".user-container").html("");
            DeleteUserByKey(snapshot.getKey())
            DisplayeUsers();
            if (snapshot.getKey() == publicKeyForDelete)
                window.location = "/Login.aspx";
        })

        function DeleteUserByKey(key) {
            for (var i = 0; i < users.length; i++) {
                if (users[i].name == key) {
                    users.splice(i, 1);
                    break
                }
            }
        }
    </script>

</body>

</html>
