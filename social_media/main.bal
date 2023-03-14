import ballerina/io;
import ballerina/uuid;
import social_media.socialDb as db;
import ballerina/persist;

public function main() returns error? {
    db:Client dbClient = check new();

    // create a new user
    db:UserInsert user1 = {
        id: uuid:createType4AsString(),
        name: "John Doe",
        email: "john@wso2.com",
        age: 30
    };

    // create a new user
    db:UserInsert user2 = {
        id: uuid:createType4AsString(),
        name: "Jane Doe",
        email: "jane@wso2.com",
        age: 25
    };

    // add users to the database
    string[] userIds = check dbClient->/users.post([user1, user2]);
    io:println("User IDs: ", userIds);

    // create a new post
    db:PostInsert post1 = {
        id: uuid:createType4AsString(),
        userId: userIds[0],
        body: "Hello World!", 
        title: "Hello",
        publishedAt: {year: 2023, month: 3, day: 1, hour: 12, minute: 30}
    };

    // create a new post
    db:PostInsert post2 = {
        id: uuid:createType4AsString(),
        userId: userIds[1],
        body: "Hello Ballerina!", 
        title: "Hello",
        publishedAt: {year: 2023, month: 3, day: 1, hour: 12, minute: 30}
    };

    // create a new post
    db:PostInsert post3 = {
        id: uuid:createType4AsString(),
        userId: userIds[1],
        body: "Hello Ballerina!", 
        title: "Hello",
        publishedAt: {year: 2023, month: 3, day: 1, hour: 12, minute: 30}
    };

    // add posts to the database
    string[] postIds = check dbClient->/posts.post([post1, post2, post3]);
    io:println("Post IDs: ", postIds);

    // get users
    stream<db:User, persist:Error?> users = dbClient->/users();
    
    // iterate through the returned stream
    check from var user in users
    do {
        io:println("Created user: ", user);
    };

    stream<UserPosts, persist:Error?> userWithPosts = dbClient->/users.get();

    // iterate through the returned stream
    check from var user in userWithPosts
    do {
        io:println("Created user with posts: ", user);
    };

    // get posts
    stream<PostUser, persist:Error?> postWithUser = dbClient->/posts();

    // iterate through the returned stream
    check from var post in postWithUser
    where post.user.name == "Jane Doe" 
    do {
        string postId = post.id;
        _ = check dbClient->/posts/[postId].put({body: "Hello Ballerina and Choreo"});
    };

    postWithUser = dbClient->/posts();
    check from var post in postWithUser
    where post.user.name == "John Doe" 
    do {
        string postId = post.id;
        _ = check dbClient->/posts/[postId].delete();
    };

    // get posts
    stream<db:Post, persist:Error?> posts = dbClient->/posts();
    check from var post in posts
    do {
        io:println("Updated post: ", post);
    };

    // get user by ID
    UserPosts user = check dbClient->/users/[userIds[0]].get();
    io:println("User by id: ", user);

}

type UserPosts record {|
    string id;
    string name;
    record {|
        string title;
    |}[] posts;
|};

type PostUser record {|
    string id;
    string title;
    record {|
        string name;
    |} user;
|};
