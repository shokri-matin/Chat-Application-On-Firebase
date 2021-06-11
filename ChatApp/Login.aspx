<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Login.aspx.cs" Inherits="ChatApp.Login" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <link href="Login.css" rel="stylesheet" />
    <link href="style.css" rel="stylesheet" />
    <link href="Content/bootstrap.min.css" rel="stylesheet" />
    <script src="Scripts/jquery-1.9.1.min.js"></script>
    <script src="firebase.js"></script>
    <script src="custom.js"></script>
    <script src="Scripts/jquery-1.9.1.js"></script>
    <script src="Scripts/bootstrap.min.js"></script>
    <script src="Scripts/angular.min.js"></script>
    <script src="Scripts/jquery.cookie.js"></script>
    <link href='https://fonts.googleapis.com/css?family=Passion+One' rel='stylesheet' type='text/css' />
    <link href='https://fonts.googleapis.com/css?family=Oxygen' rel='stylesheet' type='text/css' />
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
    <title>Login</title>
</head>
<body>
    <form id="form1" runat="server">
        <div class="container">
            <div class="row main">
                <div class="panel-heading">
                    <div class="panel-title text-center">
                        <h1 class="title">Login to AppChat</h1>
                        <hr />
                    </div>
                </div>
                <div class="main-login main-center">
                    <div class="form-group">
                        <label for="name" class="cols-sm-2 control-label">Your Name</label>
                        <div class="cols-sm-10">
                            <div class="input-group">
                                <span class="input-group-addon"><i class="fa fa-user fa" aria-hidden="true"></i></span>
                                <input type="text" class="form-control" name="name" id="name" placeholder="Enter your Name" />
                            </div>
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="email" class="cols-sm-2 control-label">Your Email</label>
                        <div class="cols-sm-10">
                            <div class="input-group">
                                <span class="input-group-addon"><i class="fa fa-envelope fa" aria-hidden="true"></i></span>
                                <input type="text" class="form-control" name="email" id="email" placeholder="Enter your Email" />
                            </div>
                        </div>
                    </div>

                    <div class="form-group ">
                        <button type="button" id="btn-login" class="btn btn-primary btn-lg btn-block login-button">Login</button>
                    </div>
                </div>
            </div>
        </div>
        <script type="text/javascript" src="assets/js/bootstrap.js"></script>

        <script>
            var usersRef = database.ref().child("users");
            var rolesRef = database.ref().child("roles");
            var rolse = [];
            //خواندن نقش های کاربران
            rolesRef.on('value', function (snapshot) {
                snapshot.forEach(function (snap) {
                    rolse.push({
                        role: snap.val().role,
                    })
                })
            })

            //زمانی که کلیک میشود پیام نام و ایمیل  کاربر را در دیتا بیس ثبت می کند
            $("#btn-login").bind("click", function () {

                var name = $("#name")
                var name_value = $.trim(name.val());

                var email = $("#email")
                var email_value = $.trim(email.val());

                var role = ""
                for (var i = 0; i < rolse.length; i++) {
                    if (name_value == "Admin")
                        role = "Admin";
                    else
                        role = "User";
                }

                usersRef.push(
                    {
                        username: name_value,
                        email: email_value,
                        role: role

                    }, function (error) {
                        if (error != null)
                            alert(error);
                    });

                window.location = "/Default.aspx?" + name_value;
            }
            )
        </script>

    </form>
</body>
</html>
