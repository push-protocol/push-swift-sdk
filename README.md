<h1 align="center">
    <a href="https://push.org/#gh-light-mode-only">
    <img width='20%' height='10%' 
src="https://res.cloudinary.com/drdjegqln/image/upload/v1686227557/Push-Logo-Standard-Dark_xap7z5.png">
    </a>
    <a href="https://push.org/#gh-dark-mode-only">
    <img width='20%' height='10%' 
src="https://res.cloudinary.com/drdjegqln/image/upload/v1686227558/Push-Logo-Standard-White_dlvapc.png">
    </a>
</h1>

<p align="center">
  <i align="center">Push Protocol is a web3 communication network, enabling cross-chain notifications and messaging for 
dapps, wallets, and services.🚀</i>
</p>

<h4 align="center">

  <a href="https://discord.com/invite/pushprotocol">
    <img src="https://img.shields.io/badge/discord-7289da.svg?style=flat-square" alt="discord">
  </a>
  <a href="https://twitter.com/pushprotocol">
    <img src="https://img.shields.io/badge/twitter-18a1d6.svg?style=flat-square" alt="twitter">
  </a>
  <a href="https://www.youtube.com/@pushprotocol">
    <img src="https://img.shields.io/badge/youtube-d95652.svg?style=flat-square&" alt="youtube">
  </a>
</h4>
</h1>
<h2>Push Swift SDK </h2> 
<p>
Push SDK provides an abstraction layer to integrate Push protocol features with your Frontend as well as Backend.
This SDK is a swift based Monorepo of packages that helps developers to :

- Build PUSH features into their DApps
  - Notifications
  - Chat
  - Group Chat
  - Push NFT Chat
  - Video Calls
- Get access to PUSH Push Nodes APIs
- Render PUSH Notifications UI

without having to write a lot of boilerplate code. All the heavy lifting is done by the SDK, so that you the developer can focus on building features and bootstrap a DApp with PUSH features in no time!
</p>
</div>


## 📚 Table of Contents
- [Modules](#-modules)
- [Getting Started](#-getting-started)
- [Resources](#resources)
- [Contributing](#contributing)

---


## 🧩 Modules

<details closed><summary>Channel</summary>

| File             | Summary                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             | Module                         |
|:-----------------|:----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|:-------------------------------|
| SearchTest.swift | The provided code snippet includes three test functions that use the PushChannel module to search for a channel by address, by name, or a non-existing channel. These tests utilize the async/await method for producing results. The tests check if the number of results found matches the expected result or not.                                                                                                                                                                                | Tests/Channel/SearchTest.swift |
| Opt.swift        | The code snippet is a collection of test cases that use the PushChannel library to subscribe and unsubscribe users to a notification channel, and verify the subscription status using mock signers for EIP712 Optin and Optout. The tests also retrieve subscriber information for the specified channel. Test assertions are made to ensure that the subscription status and subscriber information are as expected.                                                                              | Tests/Channel/Opt.swift        |
| GetChannel.swift | The code defines three test functions that utilize the Push API to retrieve information on various channels. The first test retrieves an existing channel and asserts that its address matches the provided address. The second test attempts to retrieve a non-existent channel and asserts that the result is nil. The third test retrieves a list of channels with pagination and asserts that at least one channel is returned and that the number of channels does not exceed the limit of 10. | Tests/Channel/GetChannel.swift |

</details>

<details closed><summary>Channels</summary>

| File              | Summary                                                                                                                                                                                                                                                                                                                                                                                                                 | Module                             |
|:------------------|:------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|:-----------------------------------|
| Channel.swift     | The provided code snippet defines a struct called "PushChannel" and provides methods to retrieve a PushChannel by ID or a list of PushChannels. The methods use the Codable protocol to decode JSON responses and provide options to specify the environment for retrieving the PushChannels.                                                                                                                           | Sources/Channels/Channel.swift     |
| Opt.swift         | The provided code snippet is an extension to the PushChannel class which contains methods for getting opt-in and opt-out messages for subscribing and unsubscribing to a push channel, respectively. It also includes methods for subscribing and unsubscribing from a push channel using a provided signer and channel address. Additionally, it includes structs for defining opt-in/out messages and request bodies. | Sources/Channels/Opt.swift         |
| Subscribers.swift | The provided code snippet is an extension of the PushChannel struct that provides functionalities for getting channel subscribers and checking if a user is subscribed to a channel. It includes options such as page and limit for pagination and encoding and decoding structs for handling request/response data. The code uses async/await syntax for handling asynchronous network requests.                       | Sources/Channels/Subscribers.swift |
| Search.swift      | The code provides a Swift extension to the PushChannel struct, which includes a SearchOptions struct and a function to search for channels based on the provided search options. The function constructs a URL using the search options, makes a GET request, and returns a decoded Channels object in an asynchronous manner. The search options include a query string, page number, limit, and environment.          | Sources/Channels/Search.swift      |

</details>

<details closed><summary>Chat</summary>

| File                | Summary                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  | Module                                  |
|:--------------------|:---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|:----------------------------------------|
| Conversation.swift  | The code snippet provides Swift helper functions to interact with a push chat service. The functions include ConversationHash for getting the hash of a conversation, Latest for retrieving the latest message of a conversation, History for retrieving multiple messages of a conversation, and decryptMessage for decrypting an encrypted message. The functions are implemented using the PushEndpoint and URLSession APIs.                                                                          | Sources/Chat/Conversation.swift         |
| UpdateProfile.swift | This code snippet provides functionalities for updating user profiles and blocking users in the PushNotification platform. It includes functions for updating user profile information and generating a hash of the updated profile. There is also a function for blocking users by providing a list of addresses to block and the user's account information. Additionally, the code defines two structs for the payloads used in the update-related functions.                                         | Sources/Chat/UpdateProfile.swift        |
| Send.swift          | This code snippet provides a set of functions to send encrypted chat messages via an HTTP request. It includes functions to encrypt and sign messages using public and private keys, get public keys for either P2P chats or group chats, send regular messages or intent messages through an HTTP request to a server, and approve messages using a signature.                                                                                                                                          | Sources/Chat/Send.swift                 |
| Requests.swift      | The provided code snippet is an extension of the PushChat API, which retrieves chat requests from a user's request box by providing options such as account, environment, and decryption preferences through the RequestOptionsType struct. The requests() function then retrieves the chats using URLSession and returns an array of Feeds, which are decrypted using the getInboxLists() function.                                                                                                     | Sources/Chat/Requests.swift             |
| Inbox.swift         | The code defines a struct `PushChat` that has three nested structs: `Feeds`, `GetChatsOptions`, and `GetChatsResponse`. `Feeds` contains properties for chat messages, while `GetChatsOptions` defines options for retrieving chats. Finally, `GetChatsResponse` provides a structure for the response from fetching chats with specific options. The code also includes a function `getChats` that retrieves chats using the `GetChatsOptions` struct, with error handling through an enum `ChatError`. | Sources/Chat/Inbox.swift                |
| GetInboxList.swift  | The provided code snippet includes functions that decrypt and verify message signatures using PGP encryption, check for updated inbox feed lists, and decrypt feeds if needed. The code utilizes the ObjectivePGP library and the Encodable protocol for struct serialization.                                                                                                                                                                                                                           | Sources/Helpers/Chat/GetInboxList.swift |

</details>

<details closed><summary>Config</summary>

| File            | Summary                                                                                                                                                                                                                                                                                                                                                                  | Module                         |
|:----------------|:-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|:-------------------------------|
| Constants.swift | The provided code includes two enumerations: ENCRYPTION_TYPE, with options for different types of encryption, and CONSTANTS, with constants for pagination and Ethereum chain IDs. The ENCRYPTION_TYPE enum also conforms to the Swift.CodingKey, Decodable, and Encodable protocols.                                                                                    | Sources/Config/Constants.swift |
| PushEnv.swift   | The provided code snippet contains an enumeration called ENV which represents different environments-STAGING, PROD, and DEV. It also has an extension defining a function-getHost-which takes an ENV argument and returns the corresponding host name based on the switch-case statement. This code snippet can be used to return the host name for a given environment. | Sources/Config/PushEnv.swift   |

</details>

<details closed><summary>Crypto</summary>

| File         | Summary                                                                                                                                                                                                                                                                                                                                                                                                                                         | Module                              |
|:-------------|:------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|:------------------------------------|
| AESGCM.swift | The provided code snippet contains a helper class called AESGCMHelper, which offers various functions for encryption and decryption using AES-GCM. The class provides functions for converting hex strings to data and bytes, deriving keys using HKDF, sealing boxes, opening boxes, and encrypting/decrypting data. The functions can be used to encrypt and decrypt messages using a secret key and other parameters such as salt and nonce. | Sources/Helpers/Crypto/AESGCM.swift |
| Pgp.swift    | This is a Swift code snippet containing functions for PGP encryption, decryption, and key generation. It includes methods for signing and verifying signatures, encoding and decoding PGP keys, and encrypting and decrypting messages. It also implements a random value generator and a filter for removing PGP-related information from input strings.                                                                                       | Sources/Helpers/Crypto/Pgp.swift    |
| Utils.swift  | This code snippet provides functions for generating a SHA256 hash of a given message, generating a random hexadecimal string of a specified length, generating a random sequence of bytes of a specified length, and generating a random alphanumeric string of a specified length. The code utilizes the CryptoKit library for the SHA256 hash and the Security framework for generating random bytes and strings.                             | Sources/Helpers/Crypto/Utils.swift  |
| AESCBC.swift | The provided code snippet contains a Swift implementation of AES-CBC encryption and decryption using CommonCrypto and CryptoKit frameworks. It provides functions for encrypting and decrypting data using a secret key. The code also includes functions for deriving the key and initialization vector (IV) from a passphrase and salt, as well as encoding a string to base64.                                                               | Sources/Helpers/Crypto/AESCBC.swift |

</details>

<details closed><summary>Endpoints</summary>

| File                  | Summary                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             | Module                                  |
|:----------------------|:--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|:----------------------------------------|
| IpfsEndpoint.swift    | This code snippet provides an extension for the PushEndpoint struct that allows users to retrieve a content identifier (CID) for a given environment and CID value. It generates a PushEndpoint instance with the specified environment and "ipfs/" followed by the given CID value as the path.                                                                                                                                                                                                                    | Sources/Endpoints/IpfsEndpoint.swift    |
| ChatEndpoint.swift    | This code provides several static functions that return instances of PushEndpoint, each with a specific endpoint path and query parameters for managing chat functionality in an application. The functions include retrieving chats, conversation hash, sending chat messages, and creating and updating chat groups, among others. The code also includes an extension of PushEndpoint.                                                                                                                           | Sources/Endpoints/ChatEndpoint.swift    |
| ChannelEndpoint.swift | The provided code snippet extends the PushEndpoint struct with several static functions that allow for the retrieval and manipulation of push notification channel related data via HTTP requests. The functions include getting channels, searching for channels, getting subscribers of a channel, checking if a user is subscribed to a channel, opting in and out of a channel. These functions require an environment parameter and may also require additional parameters depending on the specific function. | Sources/Endpoints/ChannelEndpoint.swift |
| PushEndpoint.swift    | The code provides the implementation of a `PushEndpoint` structure that includes several functions to create URLs based on different parameters, such as user accounts, user feeds, and user requests. The struct includes a `url` computed property that returns the constructed URL. The code relies on the `Foundation` framework for URL creation.                                                                                                                                                              | Sources/Endpoints/PushEndpoint.swift    |

</details>

<details closed><summary>Eth</summary>

| File         | Summary                                                                                                                                                                                                                                                                                                                                                                                   | Module                           |
|:-------------|:------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|:---------------------------------|
| Signer.swift | The provided code snippet defines two protocols, Signer and TypedSinger, both with functions to obtain cryptographic signatures and address information. The Signer protocol uses the EIP191 standard and the TypedSigner protocol uses the EIP712 standard. Both protocols support asynchronous operations and error handling. The required dependencies are CryptoSwift and Foundation. | Sources/Helpers/Eth/Signer.swift |
| Wallet.swift | This code snippet defines a struct called Wallet, which contains a signer and an account address. An extension to the Wallet struct provides a function to get an EIP191 signature, which takes a message string and an optional version parameter and returns a formatted signature string. The functions make use of asynchronous programming using Swift's async/await syntax.         | Sources/Helpers/Eth/Wallet.swift |

</details>

<details closed><summary>Group</summary>

| File                         | Summary                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      | Module                                        |
|:-----------------------------|:---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|:----------------------------------------------|
| UpdateGroupTests.swift       | This code snippet tests the functionality of updating a group chat's description, name, and image by calling the provided functions from the PushChat library. The code uses XCTest for testing and incorporates asynchronous programming. Additionally, there is a commented-out function that would test adding a new member to the chat.                                                                                                                                                                                                  | Tests/Chat/Group/UpdateGroupTests.swift       |
| GroupConversationTests.swift | The code snippet is a unit test case for the `testGroupConversationHash` function in `GroupChatConversationTests` class. It calls the `PushChat.ConversationHash()` function to generate a hash value for a group conversation using a conversation ID and user account address, and then compares it with an expected value. The test also checks if the `ConversationHash()` function returns nil for an empty conversation.                                                                                                               | Tests/Chat/Group/GroupConversationTests.swift |
| GetGroupTests.swift          | The code defines two test functions for the function `PushChat.getGroup()` which retrieves an existing group chat and a non-existing group chat. It uses the `XCTest` framework for unit testing and the `Push` framework for push notifications. The `async` keyword indicates that the functions are asynchronous and may `throw` errors. The tests confirm the expected behavior of the `getGroup()` function by asserting that the returned group object matches the expected group or is `nil`.                                         | Tests/Chat/Group/GetGroupTests.swift          |
| SendGroupMsgTests.swift      | The provided code snippet includes two test functions for sending messages to public and private group chats using the Push API. The tests verify that the sent messages can be correctly encrypted and decrypted and that they contain the correct content. The code requires the user's Ethereum address and PGP private key for authentication purposes.                                                                                                                                                                                  | Tests/Chat/Group/SendGroupMsgTests.swift      |
| CreateGroupTests.swift       | The provided code utilizes the Push framework to create a group chat with certain specifications, including a name, description, image, and list of members. The test ensures that the group is properly created and includes assertions for various properties. The code also accounts for potential errors and uses async/await to handle asynchronous data retrieval.                                                                                                                                                                     | Tests/Chat/Group/CreateGroupTests.swift       |
| GetGroup.swift               | The code snippet is an extension on the PushChat class that facilitates getting a specific chat group's details by making a GET request to the server using URLSession. Upon successful retrieval of data in JSON format, the data is decoded into a PushChat.PushGroup instance. If the HTTP response status code is 400, the function returns nil, else if the status code is within the 200...299 range, the decoded data is returned.                                                                                                    | Sources/Chat/Group/GetGroup.swift             |
| UpdateGroup.swift            | This code snippet defines a function to update a group chat with updated group information, including its name, description, image, members, and admins. It first generates a verification proof for the update, then sends an HTTP request with the new payload to the server to update the group's information. It also includes auxiliary functions to validate and format the input parameters, as well as utilities to handle hashing and signing operations.                                                                           | Sources/Chat/Group/UpdateGroup.swift          |
| CreateGroup.swift            | This code provides functionalities for creating a group chat using Push SDK with options for name, description, image, members, and public status. The options are validated and formatted before being encoded in a payload and sent to the createGroupService function for posting to the PushChat API. The hash is generated and signed using Pgp, and the verification proof is included in the payload. Any errors are caught and logged for debugging purposes.                                                                        | Sources/Chat/Group/CreateGroup.swift          |
| Group.swift                  | The code provides an enum for error handling and an extension for a "PushChat" feature that allows the creation of group chats with various properties such as group name, members, and verification proof. The extension contains a nested struct called "PushGroup" that consists of properties for this chat feature, including an array of members, contract addresses, and group details. The extension also includes a nested struct called "Member" that has properties for a member's wallet, public key, isAdmin status, and image. | Sources/Chat/Group/Group.swift                |

</details>

<details closed><summary>Helper</summary>

| File                   | Summary                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  | Module                              |
|:-----------------------|:-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|:------------------------------------|
| AddressTests.swift     | The provided code snippet includes a unit test that checks the validity of Ethereum addresses using the `Push` library. The test includes three valid addresses and can be extended to include invalid ones. The test executes asynchronously and will throw an error if the addresses are not valid.                                                                                                                                                                                                                    | Tests/Helper/AddressTests.swift     |
| IpfsTests.swift        | The code snippet defines two test functions that test the functionality of the Push getCID() function. The first one tests if the function returns the expected message properties for a valid CID, while the second tests if the function throws an error for an invalid CID. The tests check for values like from/to CAIP10, message type/content, encryption type, signature and encrypted secret.                                                                                                                    | Tests/Helper/IpfsTests.swift        |
| AESGCMTests.swift      | Error generating file summary. Exception: Client error '400 Bad Request' for url 'https://api.openai.com/v1/chat/completions'                                                                                                                                                                                                                                                                                                                                                                                            | Tests/Helper/AESGCMTests.swift      |
|                        | For more information check: https://httpstatuses.com/400                                                                                                                                                                                                                                                                                                                                                                                                                                                                 |                                     |
| CryptoUtilsTests.swift | The provided code snippet is written in Swift and contains two test functions for testing random hexadecimal string generation and SHA256 hash generation. The functions use the XCTest framework for unit tests and the Push framework for push notifications. The test functions ensure that the generated hexadecimal strings have the correct length and are not equal to each other, while the SHA256 hash function generates a hash string for a given message and checks that it matches the expected hash value. | Tests/Helper/CryptoUtilsTests.swift |
| PgpTests.swift         | Error generating file summary. Exception: Client error '400 Bad Request' for url 'https://api.openai.com/v1/chat/completions'                                                                                                                                                                                                                                                                                                                                                                                            | Tests/Helper/PgpTests.swift         |
|                        | For more information check: https://httpstatuses.com/400                                                                                                                                                                                                                                                                                                                                                                                                                                                                 |                                     |
| AESCBCTests.swift      | The provided code snippet contains a Swift implementation of AES-CBC encryption and decryption, along with key generation and test cases using the XCTest framework. The code uses the AESCBCHelper class to perform encryption and decryption, and the Push library for asynchronous testing. The test cases validate the correctness of the AES-CBC implementation for different scenarios.                                                                                                                            | Tests/Helper/AESCBCTests.swift      |
| SignerTests.swift      | The provided code snippet contains unit tests for a signer class that can generate EIP-191 signatures and derive AES secrets for a Push Wallet. The tests use XCTestCase and async/await keywords to ensure the functionality of the SignerPrivateKey and Wallet classes.                                                                                                                                                                                                                                                | Tests/Helper/SignerTests.swift      |

</details>

<details closed><summary>Helpers</summary>

| File                     | Summary                                                                                                                                                                                                                                                                                                                                                                                                                                                                | Module                                        |
|:-------------------------|:-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|:----------------------------------------------|
| Accounts.swift           | The provided code snippet contains two functions written in Swift. The first function generates a random private key for a cryptocurrency account of a specified length using letters and digits, and returns it as a string. The second function generates a random Ethereum address by first creating a random string of hexadecimal digits and then passing it through the EthereumAddress class to create a valid Ethereum address string, which is then returned. | Tests/helpers/Accounts.swift                  |
| Signer.swift             | The code snippet defines three structs: SignerPrivateKey for signing Ethereum transactions, and two mock signers for opting in and opting out. The SignerPrivateKey struct uses the CryptoSwift, Push, Web3Core and web3swift frameworks to sign personal messages and retrieve the account address. The two mock signers implement the TypedSinger protocol to provide hardcoded EIP712 signatures and return a pre-defined Ethereum address.                         | Tests/helpers/Signer.swift                    |
| GroupChatValidator.swift | The code snippet provides two functions, createGroupOptionValidator and updateGroupOptionValidator, that validate if the input options are valid for creating or updating a group. It verifies if the name and description of the group are not empty and do not exceed specific character limits, if the members are not null and have valid ETH addresses. Any violation of these rules results in a fatal error.                                                    | Sources/Chat/helpers/GroupChatValidator.swift |
| Address.swift            | The code snippet provides various functions related to Ethereum addresses and their conversion to the CAIP-10 format. The functions include validation of ETH addresses, conversion of wallets to and from PCAIP-10 format, and retrieval of user DID. The code also handles group chat ID and a fallback function to get the CAIP IP address.                                                                                                                         | Sources/Helpers/Address.swift                 |

</details>

<details closed><summary>Ipfs</summary>

| File      | Summary                                                                                                                                                                                                                                                                   | Module                         |
|:----------|:--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|:-------------------------------|
| Cid.swift | The code snippet defines a struct for a message with various properties and a function to retrieve a message by ID from a remote server. The function uses an HTTP request to retrieve the message data, decodes it as a JSON object, and returns it as a Message object. | Sources/Helpers/Ipfs/Cid.swift |

</details>

<details closed><summary>P2p</summary>

| File                    | Summary                                                                                                                                                                                                                                                                                                                                                  | Module                                 |
|:------------------------|:---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|:---------------------------------------|
| ConversationTests.swift | The provided code snippet includes a test case that checks the function `PushChat.ConversationHash()` for generating a hash of a conversation. The function returns a hash as a string that is used to identify a unique conversation. The test case tests the function for empty conversation and also checks the length of the returned hash.          | Tests/Chat/P2P/ConversationTests.swift |
| GetChatsTests.swift     | The provided code snippet contains three test functions designed to test Push notifications in an iOS app. These tests cover functionality such as retrieving chat feeds and message history, as well as sending and receiving chat requests between users. The code uses the XCTest framework and Swift's async/await feature for asynchronous testing. | Tests/Chat/P2P/GetChatsTests.swift     |
| SendTests.swift         | Error generating file summary. Exception: Client error '400 Bad Request' for url 'https://api.openai.com/v1/chat/completions'                                                                                                                                                                                                                            | Tests/Chat/P2P/SendTests.swift         |
|                         | For more information check: https://httpstatuses.com/400                                                                                                                                                                                                                                                                                                 |                                        |

</details>

<details closed><summary>Project.xcworkspace</summary>

| File                     | Summary                                                                                                                                                                                                                                                            | Module                                                                         |
|:-------------------------|:-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|:-------------------------------------------------------------------------------|
| contents.xcworkspacedata | This code snippet defines an XML workspace with version 1.0 and includes a reference to a file located in the same place as the workspace itself. It provides a simple structure for organizing and referencing files within a project or development environment. | PushIosDemo/PushIosDemo.xcodeproj/project.xcworkspace/contents.xcworkspacedata |

</details>

<details closed><summary>Pushiosdemo</summary>

| File                 | Summary                                                                                                                                                                                                                                                                                                                                                                | Module                                       |
|:---------------------|:-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|:---------------------------------------------|
| PushIosDemoApp.swift | The provided code snippet is a standard template for a SwiftUI app that creates a single window scene with the ContentView as its content. The app is intended for use with push notifications on an iOS platform.                                                                                                                                                     | PushIosDemo/PushIosDemo/PushIosDemoApp.swift |
| ContentView.swift    | The code creates a simple SwiftUI view with a button for initiating the connection to Wallet Connect. When the button is clicked, it calls the'connect()' function that fetches a user account using an async function from the "Push" package, and logs the result to console. An alert is also displayed when the button is clicked, indicating that it was clicked. | PushIosDemo/PushIosDemo/ContentView.swift    |

</details>

<details closed><summary>Pushiosdemo.xcodeproj</summary>

| File            | Summary                                                                                                                       | Module                                            |
|:----------------|:------------------------------------------------------------------------------------------------------------------------------|:--------------------------------------------------|
| project.pbxproj | Error generating file summary. Exception: Client error '400 Bad Request' for url 'https://api.openai.com/v1/chat/completions' | PushIosDemo/PushIosDemo.xcodeproj/project.pbxproj |
|                 | For more information check: https://httpstatuses.com/400                                                                      |                                                   |

</details>

<details closed><summary>Root</summary>

| File             | Summary                                                                                                                                                                                                                                                                                                                                                                | Module           |
|:-----------------|:-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|:-----------------|
| Package.resolved | The code snippet is a JSON object that contains information about different open-source libraries used in a project. The "pins" array includes four libraries with their identities, kind, location, and state (revision and version). The "version" key signifies the format version of the JSON object.                                                              | Package.resolved |
| Package.swift    | This snippet defines a Swift package named "Push" with a library target that depends on three external packages via SPM: ObjectivePGP, CryptoSwift, and web3swift. The package has a minimum version requirement of Swift 5.8 and supports iOS 14 and macOS 11 platforms. Additionally, there is a test target that depends on the Push library and web3swift package. | Package.swift    |

</details>

<details closed><summary>Scripts</summary>

| File    | Summary                                                                                                                                                                                                                                                                  | Module          |
|:--------|:-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|:----------------|
| lint.sh | The provided code snippet runs the swift-format tool in recursive mode on all files in the current directory and its subdirectories. The "-rip" flag allows the tool to make changes directly to the files instead of simply outputting suggested changes.               | scripts/lint.sh |
| test.sh | The bash script installs xcpretty via Homebrew, a tool for formatting Xcode outputs. It then checks for a command line argument, and if present, filters the Swift test output according to the argument. Finally, it pipes the formatted output to xcpretty with color. | scripts/test.sh |

</details>

<details closed><summary>Swiftpm</summary>

| File             | Summary                                                                                                                                                                                                                                                                                                                                                                                                                           | Module                                                                                      |
|:-----------------|:----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|:--------------------------------------------------------------------------------------------|
| Package.resolved | The provided code snippet is a JSON configuration file that contains information about various remote source control repositories, such as their identity, location and version. The repositories are mainly related to Swift programming language and cryptography, including libraries such as BigInt, CryptoSwift, and secp256k1. This file can be used to manage and track dependencies in a Swift-based development project. | PushIosDemo/PushIosDemo.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved |

</details>

<details closed><summary>User</summary>

| File                  | Summary                                                                                                                                                                                                                                                                                                                                                                                                                                                                  | Module                           |
|:----------------------|:-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|:---------------------------------|
| CreateUserTests.swift | The provided code snippet contains test cases for creating a new user and checking if a user already exists using the Push and Web3Swift frameworks. The tests are carried out using XCTest and utilize async/await functions. The tests include verifying the user's DID, wallet address, and encrypted private key.                                                                                                                                                    | Tests/User/CreateUserTests.swift |
| GetFeedsTests.swift   | The code defines two test cases for the `PushUser.getFeeds` method, which retrieves feeds for a specified user in a specified environment. The first test case validates that feeds are returned successfully, while the second test case checks if an error is thrown when an invalid user address is provided as input. The tests are built using the XCTest framework.                                                                                                | Tests/User/GetFeedsTests.swift   |
| GetTests.swift        | The code snippet provides test cases for the getUser functionality of the PushUser class. The test cases check if the function returns the expected results under different scenarios such as checking if the user exists or not, if the user has an Ethereum address, and if the user's profile is created. The tests are performed using the XCTest framework.                                                                                                         | Tests/User/GetTests.swift        |
| UpdateUserTests.swift | The provided code snippet contains two test functions for updating user profile and blocking users in a PushUser account. The functions utilize the Push framework and XCTest for running unit tests. The tests make use of randomly generated Ethereum addresses and require a UserAddress and UserPrivateKey to function properly.                                                                                                                                     | Tests/User/UpdateUserTests.swift |
| GetFeeds.swift        | The provided code snippet defines data structures for working with push notifications, including additional metadata and payload data. It also includes options for fetching feed data and a function for requesting feeds from the server. The code uses Swift's Codable protocol to enable serialization and deserialization of JSON data.                                                                                                                             | Sources/User/GetFeeds.swift      |
| CreateUser.swift      | The code snippet provides a set of functions to create a PushUser with secure and seamless chat functionalities, encrypting keys and signing messages along the process. It defines several structs and enums, sends HTTP requests to a given endpoint, and handles errors with specific error messages. Additionally, it offers a progress hook type to update the user on the current progress and an option to create an empty user.                                  | Sources/User/CreateUser.swift    |
| User.swift            | The provided code snippet defines a public struct called PushUser, which includes properties such as user information and functions to obtain PGP public keys and user profiles. Additionally, it includes an extension for the PushUser struct that facilitates the retrieval of user information from a remote server using async/await functions. The code also includes an error-throwing function to check if a user profile has been created on the remote server. | Sources/User/User.swift          |
| DecryptPgp.swift      | This code snippet extends the PushUser class with a DecryptPGPKey function that takes an encrypted private key, decrypts it using AESGCMHelper and returns the plaintext private key. The decryption key is generated using the Eip191Signature and the signer. The EncryptedPrivateKey struct defines the ciphertext, version, salt, nonce and preKey.                                                                                                                  | Sources/User/DecryptPgp.swift    |

</details>

<details closed><summary>Xcshareddata</summary>

| File                         | Summary                                                                                                                                                                                                                                                                                              | Module                                                                                          |
|:-----------------------------|:-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|:------------------------------------------------------------------------------------------------|
| IDEWorkspaceChecks.plist     | The code defines a property list with a key-value pair. The key is IDEDidComputeMac32BitWarning and its value is true. This is related to Apple's Integrated Development Environment (IDE) and suggests that it may have computed a warning related to the use of 32-bit software on a Mac computer. | PushIosDemo/PushIosDemo.xcodeproj/project.xcworkspace/xcshareddata/IDEWorkspaceChecks.plist     |
| WorkspaceSettings.xcsettings | This is an XML file written in the Property List format. It begins with the header and defines a root element of a dictionary object with no content. The purpose of this code snippet is unclear without additional context.                                                                        | PushIosDemo/PushIosDemo.xcodeproj/project.xcworkspace/xcshareddata/WorkspaceSettings.xcsettings |

</details>

---

## 🚀 Getting Started

### 🖥 Installation

1. Clone the push-swift-sdk repository:
```sh
git clone https://github.com/ethereum-push-notification-service/push-swift-sdk
```

2. Change to the project directory:
```sh
cd push-swift-sdk
```

3. Install the dependencies:
```sh
swift build
```

### 🤖 Using push-swift-sdk

```sh
.build/debug/myapp
```

### 🧪 Running Tests
```sh
swift test
```

---

## Resources
- **[Website](https://push.org)** To checkout our Product.
- **[Docs](https://docs.push.org/developers/)** For comprehensive documentation.
- **[Blog](https://medium.com/push-protocol)** To learn more about our partners, new launches, etc.
- **[Discord](discord.gg/pushprotocol)** for support and discussions with the community and the team.
- **[GitHub](https://github.com/ethereum-push-notification-service)** for source code, project board, issues, and pull requests.
- **[Twitter](https://twitter.com/pushprotocol)** for the latest updates on the product and published blogs.


## Contributing

Push Protocol is an open source Project. We firmly believe in a completely transparent development process and value any contributions. We would love to have you as a member of the community, whether you are assisting us in bug fixes, suggesting new features, enhancing our documentation, or simply spreading the word. 

- Bug Report: Please create a bug report if you encounter any errors or problems while utilising the Push Protocol.
- Feature Request: Please submit a feature request if you have an idea or discover a capability that would make development simpler and more reliable.
- Documentation Request: If you're reading the Push documentation and believe that we're missing something, please create a docs request.


Read how you can contribute <a href="https://github.com/ethereum-push-notification-service/push-sdk/blob/main/contributing.md">HERE</a>

Not sure where to start? Join our discord and we will help you get started!


<a href="discord.gg/pushprotocol" title="Join Our Community"><img src="https://www.freepnglogos.com/uploads/discord-logo-png/playerunknown-battlegrounds-bgparty-15.png" width="200" alt="Discord" /></a>

## License
Check out our License <a href='https://github.com/ethereum-push-notification-service/push-sdk/blob/main/license-v1.md'>HERE </a>
