var my_saved_cookie = null;
var curUrlObj = null;
var curOptions = null;

function getCookie(jqXHR) {
    var header = jqXHR.getAllResponseHeaders();
    var match = header.match(/(Set-Cookie|set-cookie): (.+?);/);
    if (match) {
        my_saved_cookie = match[2];
        // alert("Received cookie : " + my_saved_cookie);
        return my_saved_cookie;
    }
    return null;
}

/**
 * Utility method to transform a JCR nodetype into a path that is safe to use in URLs
 * @param nodeType the JCR nodetype name
 */
function nodeTypeToPath(nodeType) {
    return nodeType.replace(/\:/, '_');
}

function getNodeData(nodePath, callback) {
    console.log("Setting up AJAX node data request");
    var nodeDataRequest = {
        url : 'http://' + jahiaServer + '/cms/wise/default/en' + nodePath + '.full.json',
        data : { escapeColon : 'true' },
        success : function(data, textStatus, jqXHR) {
            getCookie(jqXHR);
            callback(data, textStatus, jqXHR);
        },
        dataType: 'json',
        error: function(jqXHR, textStatus, errorThrown) {
            alert('Error retrieving node at ' + nodePath + ':' + textStatus + " error:" + errorThrown);
        },
        timeout: 5000
    }
    if (my_saved_cookie != null) {
        nodeDataRequest.headers = { Cookie: my_saved_cookie };
    }
    console.log('Executing AJAX query to ' + nodeDataRequest.url);
    $.ajax(nodeDataRequest);
}

function createNode(parentNodePath, nodeType, extraData, callback) {
    console.log("Setting up AJAX node creation request");
    var nodeCreationRequest = {
        url : 'http://' + jahiaServer + '/cms/wise/default/en' + parentNodePath + '/*',
        type: 'POST',
        data : {
            jcrNodeType : nodeType
        },
        success : function(data, textStatus, jqXHR) {
            getCookie(jqXHR);
            callback(data, textStatus, jqXHR);
        },
        dataType: 'json',
        error: function(jqXHR, textStatus, errorThrown) {
            alert('Error executing node creation AJAX query:' + textStatus + " thrown:" + errorThrown);
        },
        timeout: 10000
    }
    if (extraData) {
        console.log("Merging extra data.");
        $.extend(nodeCreationRequest.data, extraData);
    }
    if (my_saved_cookie != null) {
        nodeCreationRequest.headers = { Cookie: my_saved_cookie };
    }
    console.log('Executing AJAX query to ' + nodeCreationRequest.url);
    $.ajax(nodeCreationRequest);
}

function resolvePageName(nodeType, mixinTypes, superTypes) {
    var pageName = '#viewNode_' + nodeTypeToPath(nodeType), pageSelector = $(pageName);
    if (pageSelector.length == 0) {
        console.log('resolvePageName: Page name ' + pageName + " not found, searching in mixinTypes");
        for (mixinType in mixinTypes) {
            pageName = '#viewNode_' + nodeTypeToPath(mixinType);
            if ($(pageName).length > 0) {
                console.log('resolvePageName: Found pageName=' + pageName);
                return pageName;
            }
        }
        console.log("resolvePageName: Nothing found in for mixinTypes, searching in superTypes");
        for (superType in superTypes) {
            pageName = '#viewNode_' + nodeTypeToPath(superType);
            if ($(pageName).length > 0) {
                console.log('resolvePageName: Found pageName=' + pageName);
                return pageName;
            }
        }
        console.log("resolvePageName: Nothing found for superTypes, defaulting to #viewNode_nt_base");
        pageName = "#viewNode_nt_base";
    } else {
        console.log('resolvePageName: Found childPageName=' + pageName);
    }
    return pageName;
}

function resolveIconName(node) {
    if (node.primaryNodeType == 'jnt:folder') {
        return 'jnt_folder';
    } else if (node.primaryNodeType == 'jnt:file') {
        return 'jnt_file';
    } else if (node.primaryNodeType == 'docnt:note') {
        return 'docnt_note';
    } else {
        return node.nodename;
    }
}

function isIgnoredType(childNodeType) {
    return ($.inArray(childNodeType, ignoreNodeTypes) !== -1);
}

function isLeafType(childNodeType) {
    return ($.inArray(childNodeType, leafNodeTypes) !== -1);
}

var alreadyVisited = [];
var currentPath = [];

function dumpObjectProperties(curObject) {

    recurseDumpObjectProperties(curObject, 0);

    alreadyVisited = [];
    currentPath = [];
}

function getNodePath(htmlNode) {

    var path = [];

    do {
        path.unshift(htmlNode.nodeName + (htmlNode.id ? ' id="' + htmlNode.id + '"' : '') + (htmlNode.className ? ' class="' + htmlNode.className + '"' : ''));
    } while ((htmlNode.nodeName.toLowerCase() != 'html') && (htmlNode = htmlNode.parentNode));

    return path.join(" > ");

}

function recurseDumpObjectProperties(curObject, depthPadding) {
    var depthPaddingString = "";
    for (i = 0; i < depthPadding; i++) {
        depthPaddingString += " ";
    }
    if ($.inArray(curObject, alreadyVisited) !== -1) {
        console.log(depthPaddingString + 'already visited object at ' + currentPath);
        return;
    }
    if (depthPadding > 4) {
        console.log(depthPaddingString + 'aborting output because of depth');
        return;
    }
    alreadyVisited.push(curObject);
    currentPath.push(curObject);
    console.log(depthPaddingString + '{');
    for (var objectPropertyKey in curObject) {
        var objectPropertyValue = curObject[objectPropertyKey];
        if (objectPropertyKey == 'outerHTML' || objectPropertyKey == 'innerHTML') {
            console.log(depthPaddingString + '   ' + objectPropertyKey + ' : \'HTML stripped\'');
        } else if (objectPropertyKey == 'outerText' || objectPropertyKey == 'innerText') {
            console.log(depthPaddingString + '   ' + objectPropertyKey + ' : \'Text stripped\'');
        } else if (typeof objectPropertyValue == 'object') {
            if (objectPropertyValue instanceof Node) {
                console.log(depthPaddingString + '   ' + objectPropertyKey + ' : ' + getNodePath(objectPropertyValue));
            } else {
                console.log(depthPaddingString + '   ' + objectPropertyKey + ' : ');
                recurseDumpObjectProperties(objectPropertyValue, depthPadding + 2);
            }
        } else if (typeof objectPropertyValue == 'function') {
            // don't dump functions, they are not needed most of the time.
        } else {
            console.log(depthPaddingString + '   ' + objectPropertyKey + ' : ' + curObject[objectPropertyKey]);
        }
    }
    console.log(depthPaddingString + '}');
    currentPath.pop();
}

/**
 * Render a node into a view specified using a page selector
 * @param pageSelector
 * @param node
 * @param nodePath
 */
function renderNode(pageSelector, node) {
// Get the page we are going to dump our content into.
    var $page = $(pageSelector), // Get the header for the page.
        $header = $page.children(":jqmData(role=header)"), // Get the content area element for the page.
        $content = $page.children(":jqmData(role=content)"), // The markup we are going to inject into the content
        // area of the page.
        markup = "";

    // Generate a list item for each item in the category
    // and add it to our markup.
    if (node.jcr_primaryType == 'jnt:file') {
        downloadFile('http://' + jahiaServer + '/files/default' + node.path, node.j_nodename);

    } else {
        // Render the template with the movies data and insert
        // the rendered HTML under the "movieList" element
        console.log('Node ' + node.path + ":");
        // dumpObjectProperties(node);
        try {
            markup = $(pageSelector + " .nodeTemplate").render(node);
        } catch (e) {
            console.log("Error rendering template for " + node.path + ":" + e.message);
        }

        $(pageSelector + " .nodeContent").html(markup);

        console.log('showNodeDetails: Setting up click functions...');
    }

    // Find the h1 element in our header and inject the name of
    // the category into it.
    console.log("Changing title...");
    $header.find("h1").html(node.text);
    console.log("Changing parent link...");
    $header.find("a").attr('href', resolvePageName(node.parentPrimaryNodeType, node.parentMixinTypes, node.parentSupertypes) + "?nodePath=" + encodeURIComponent(node.parentPath));

    // Pages are lazily enhanced. We call page() on the page
    // element to make sure it is always enhanced before we
    // attempt to enhance the listview markup we just injected.
    // Subsequent calls to page() are ignored since a page/widget
    // can only be enhanced once.
    $page.page();

    console.log("Enhancing page components");
    $(pageSelector + " .nodeContent").trigger("create");

    // Enhance the listview we just injected.
    // $content.find(":jqmData(role=listview)").listview();

    var callbackFunction = pageSelector.substring("#viewNode_".length) + "_pageInit";
    if (window[callbackFunction]) {
        console.log('Calling page init call back ' + callbackFunction);
        window[callbackFunction](node);
    } else {
        console.log("No page init callback with name " + callbackFunction + " found.")
    }


    return $page;
}

function refreshNodeDetails() {
    if (curUrlObj && curOptions) {
        showNodeDetails(curUrlObj, curOptions, true);
    }
}

function showNodeDetails(urlObj, options, refresh) {
    var nodePath = decodeURIComponent(urlObj.hash.replace(/.*nodePath=/, ""));
    // var nodePath = decodeURIComponent(options.pageData.nodePath);
    console.log('jahiawise.showNodeDetails urlObj=');
    dumpObjectProperties(urlObj);
    console.log('jahiawise.showNodeDetails options=');
    dumpObjectProperties(options);
    console.log('jahiawise.showNodeDetails refresh=');
    dumpObjectProperties(refresh);
    console.log('jahiawise.showNodeDetails nodePath=');
    dumpObjectProperties(nodePath);
    curUrlObj = urlObj;
    curOptions = options;
    // Get the object that represents the category we
    // are interested in. Note, that at this point we could
    // instead fire off an ajax request to fetch the data, but
    // for the purposes of this sample, it's already in memory.
    getNodeData(nodePath, function (data, textStatus, jqXHR) {
        var node = data;
        // The pages we use to display our content are already in
        // the DOM. The id of the page we are going to write our
        // content into is specified in the hash before the '?'.
        var pageSelector = urlObj.hash.replace(/\?.*$/, "");
        console.log('pageSelector=' + pageSelector + ' node=' + node);
        if (node) {

            if ($(pageSelector).length == 0) {
                console.log("showNodeDetails: unable to find page with selector " + pageSelector + ", aborting rendering !");
                return;
            }
            var $page = renderNode(pageSelector, node);

            // We don't want the data-url of the page we just modified
            // to be the url that shows up in the browser's location field,
            // so set the dataUrl option to the URL for the category
            // we just loaded.
            options.dataUrl = urlObj.href;

            // Now call changePage() and tell it to switch to
            // the page we just modified.
            if (!refresh) {
                console.log("showNodeDetails: Now changing page dynamically...options.pageContainer=" + options.pageContainer);
                $.mobile.changePage($page, options);
            }
        } else {
            console.log("No valid node for " + nodePath + " was found !");
        }
    });
}

function displayNode(node) {
    console.log('Node ' + node.path + ':');
    // dumpObjectProperties(node);
    var newMarkup = '';
    var childPageName = resolvePageName(node.primaryNodeType, node.mixinTypes, node.supertypes);
    newMarkup += "<a href='" + childPageName + "?nodePath=" + encodeURIComponent(node.path) + "'>";

    newMarkup += '<h3>' + node.jcr_title + '</h3>';
    // newMarkup += '<p>'+node.jcr_description+'</p>';
    newMarkup += '<p>Last modification by ' + node.j_lastPublishedBy + '</p>';
    newMarkup += '<p>' + prettyDate(new Date(node.j_lastPublished)) + '</p>';
    if (false) {
        newMarkup += '<table>';
        $.each(node, function(key, value) {
            newMarkup += key + '=' + value + '<br/>';
        });
        newMarkup += '</p>';
    }
    newMarkup += '</a>';

    return newMarkup;
}

function executeFind() {

    var findRequest = {
        url : "http://" + jahiaServer + "/cms/find/default/en",
        data : { query : "select * from [docmix:docspace]", depthLimit: "2", escapeColon: 'true' },
        success : function(data, textStatus, jqXHR) {
            // alert('Find AJAX request successful.' + textStatus);
            getCookie(jqXHR);
            if ($.isArray(data)) {
                var list = $('#docspaceList');
                list.html("");
                $.each(data, function (index, value) {
                    var node = value.node;
                    var nodePrimaryType = node.jcr_primaryType;
                    if (!isIgnoredType(nodePrimaryType)) {
                        var newMarkup = displayNode(node);
                        list.append($(document.createElement('li')).html(newMarkup));
                    }
                });

                list.listview("refresh");
            } else {
                alert('Data=' + data);
            }
        },
        error: function(jqXHR, textStatus, errorThrown) {
            alert('Error executing find AJAX query:' + textStatus + " thrown:" + errorThrown);
        },
        timeout: 5000
    }
    // alert("Setting cookie: " + my_saved_cookie);
    if (my_saved_cookie != null) {
        findRequest.headers = { Cookie: my_saved_cookie };
    }
    console.log("Executing AJAX request to " + findRequest.url);
    $.ajax(findRequest);
}

function login() {
    var request = {
        url: "http://" + jahiaServer + "/cms/login",
        type: 'POST',
        success: function(data, textStatus, jqXHR) {
            // alert('Login AJAX request successful.' + textStatus);
            getCookie(jqXHR);
            executeFind();
        },
        error: function(jqXHR, textStatus, errorThrown) {
            alert('Error executing login AJAX query:' + textStatus + " thrown:" + errorThrown);
        },
        timeout: 3000
    };

    if (my_saved_cookie != null) {
        // alert("Setting cookie: " + my_saved_cookie);
        request.headers = { Cookie: my_saved_cookie };
    }

    request.data = {
        username: jahiaUserName,
        password: jahiaUserPassword,
        redirectActive: "no",
        redirect: "no",
        restMode: "true"
    };

    console.log("Executing AJAX request to " + request.url);
    $.ajax(request);
}

function downloadFile(downloadURL, fileName) {
    console.log('Downloading ' + downloadURL + ' to file ' + fileName);
    window.requestFileSystem(
        LocalFileSystem.PERSISTENT, 0,
        function onFileSystemSuccess(fileSystem) {
            fileSystem.root.getFile(
                "dummy.html", {create: true, exclusive: false},
                function gotFileEntry(fileEntry) {
                    var sPath = fileEntry.fullPath.replace("dummy.html", "");
                    var fileTransfer = new FileTransfer();
                    fileEntry.remove();

                    fileTransfer.download(
                        downloadURL,
                        sPath + fileName,
                        function(theFile) {
                            console.log("Download complete: " + theFile.toURL());
                            showLink(theFile.toURL(), fileName);
                        },
                        function(error) {
                            console.log("Download error source " + error.source);
                            console.log("Download error target " + error.target);
                            console.log("Upload error code: " + error.code);
                        }
                    );
                },
                fail);
        },
        fail);

}

function showLink(url, fileName) {

    $('#downloadReady').html('<iframe frameborder="0" src="' + url + '" style="width:100%; height:100%; overflow: scroll" scrolling="auto"></iframe>');

    /*
     $('<a data-role="button" rel="external" target="_blank" href="' + url + '">Open ' + fileName + '</a>').appendTo("#downloadReady").trigger("refresh");
     */

}


function fail(evt) {
    console.log('File system access failed with error code');
    console.log(evt.target.error.code);
    console.log('and event:');
    console.log(evt);
}

function sendImage(src, path) {

    // Set the image source [library || camera]
    src = (src == 'Library') ? Camera.PictureSourceType.PHOTOLIBRARY : Camera.PictureSourceType.CAMERA;

    // Aquire the image -> Phonegap API
    navigator.camera.getPicture(captureSuccess, captureFail, {quality: 45, sourceType: src, destinationType: Camera.DestinationType.FILE_URI});

    var uploadSuccess = function(r) {
        console.log("Code = " + r.responseCode);
        console.log("Response = " + r.response);
        console.log("Sent = " + r.bytesSent);
        alert('Image uploaded successfully.')
        refreshNodeDetails();
    }

    var uploadFail = function(error) {
        alert("An error has occurred: Code = " + error.code + " Source=" + error.source + " Target=" + error.target + " HTTP status=" + error.http_status);
    }

    // Successfully aquired image data -> base64 encoded string of the image file
    function captureSuccess(imageURI) {
        console.log('Image successfully captured at ' + imageURI);
        var url = 'http://' + jahiaServer + '/cms/wise/default/en' + path + '.uploadFile.do';
        var params = {file: imageURI};

        var options = new FileUploadOptions();
        options.fileKey = "file";
        var fileName = imageURI.substr(imageURI.lastIndexOf('/') + 1);
        if (fileName.lastIndexOf('.') == -1) {
            console.log('Missing extension, adding .jpg extension to file name ' + fileName);
            fileName += '.jpg'
        }
        options.fileName = fileName;
        options.mimeType = "image/jpeg";

        var params = new Object();
        //params.newVersion = "true";
        params.jcrNodeType = "jnt:file";
        params.jcrReturnContentType = "json";
        params.jcrVersion = "true";
        params.jcrReturnContentTypeOverride = 'application/json';
        /*
         params.jcrRedirectTo="<c:url value='${url.base}${renderContext.mainResource.node.path}'/>";
         params.jcrNewNodeOutputFormat="${renderContext.mainResource.template}.html";
         */

        options.params = params;

        var ft = new FileTransfer();
        console.log('Now uploading image ' + imageURI + ' to url ' + url + '...');
        ft.upload(imageURI, url, uploadSuccess, uploadFail, options);

    }

    function captureFail(message) {
        alert(message);
    }
}

function readConfigFile(successCallback, failureCallback) {
    window.requestFileSystem(LocalFileSystem.PERSISTENT, 0, function (fileSystem) {
        fileSystem.root.getFile("config.txt", {create: false, exclusive: false}, function (fileEntry) {
            fileEntry.file(function (file) {
                var reader = new FileReader();
                reader.onloadend = function(evt) {
                    console.log("Read as text");
                    console.log(evt.target.result);
                    var configText = evt.target.result;
                    var configData = configText.split(',');
                    if (configData.length == 3) {
                        jahiaServer = configData[0];
                        jahiaUserName = configData[1];
                        jahiaUserPassword = configData[2];
                        console.log('Config read successfully, calling success callback...');
                        successCallback();
                    } else {
                        console.log('Invalid length for configData: ' + configText);
                        failureCallback();
                    }
                };
                reader.readAsText(file);
            }, failConfigRead);
        }, failConfigRead);
    }, failConfigRead);
}

function failConfigRead(error) {
    console.log('Error reading config file config.txt:')
    console.log(error.code);
    console.log('Detailed error:');
    console.log(error);
}

function writeConfigFile(successCallback) {
    window.requestFileSystem(LocalFileSystem.PERSISTENT, 0, function (fileSystem) {
        fileSystem.root.getFile("config.txt", {create: true, exclusive: false}, function (fileEntry) {
            fileEntry.createWriter(function (writer) {
                writer.onwrite = function(evt) {
                    console.log("Config write successfull.");
                    if (successCallback) {
                        successCallback();
                    }
                };
                writer.write(jahiaServer + ',' + jahiaUserName + ',' + jahiaUserPassword);
            }, failConfigWrite);
        }, failConfigWrite);
    }, failConfigWrite);
}

function failConfigWrite(error) {
    console.log('Error writing config file config.txt:')
    console.log(error.code);
}


// Wait for Cordova to load
function initApp() {

    console.log('Attempting to read config file...');
    readConfigFile(function success() {
        console.log('Config read successfully, logging in...');
        login();
    }, function failure() {
        console.log('Failed reading config, writing default config.')
        writeConfigFile();
    });


// Listen for any attempts to call changePage().
    $(document).bind("pagebeforechange", function(event, data) {

        console.log('jahiawise.pagebeforechange data=');
        dumpObjectProperties(data);

        // We only want to handle changePage() calls where the caller is
        // asking us to load a page by URL.
        if (typeof data.toPage === "string") {
            console.log("Event pagebeforechange using string=" + data.toPage);

            // We are being asked to load a page by URL, but we only
            // want to handle URLs that request the data for a specific
            // node.
            var u = $.mobile.path.parseUrl(data.toPage), detailsRe = /^#viewNode_/, settingsRe = /^#settings/;

            if (u.hash.search(detailsRe) !== -1) {
                showNodeDetails(u, data.options, false);
                // Make sure to tell changePage() we've handled this call so it doesn't
                // have to do anything.
                event.preventDefault();
            } else if (u.hash.search(settingsRe) !== -1) {
                $("input[name='jahiaServerURL']").val(jahiaServer);
                $("input[name='jahiaUserName']").val(jahiaUserName);
                $("input[name='jahiaUserPassword']").val(jahiaUserPassword);
            }
        }
    });

    /*
     $(':jqmData(url^=MYPAGEID)').live('pagebeforecreate',
     function(event) {
     $(this).filter(':jqmData(url*=ui-page)').find(':jqmData(role=header)')
     .prepend('<a href="#" data-rel="back" data-icon="back">Back</a>')
     });
     */


    var element = document.getElementById('deviceProperties');

    element.innerHTML = 'Device Name: ' + device.name + '<br />' +
        'Device Cordova: ' + device.cordova + '<br />' +
        'Device Platform: ' + device.platform + '<br />' +
        'Device UUID: ' + device.uuid + '<br />' +
        'Device Version: ' + device.version + '<br />' +
        'Connection type: ' + navigator.network.connection.type + '<br />';

    // register JSRender converters and helpers
    $.views.converters({
        encodeURIComponent: function (value) {
            return encodeURIComponent(value);
        }
    });

    $.views.helpers({
        isIgnoredType: function (nodeType) {
            return isIgnoredType(nodeType);
        },
        isLeafType: function (nodeType) {
            return isLeafType(nodeType);
        },
        getChildPageName: function (node) {
            return resolvePageName(node.primaryNodeType, node.mixinTypes, node.supertypes);
        },
        getParentPageName: function (node) {
            return resolvePageName(node.parentPrimaryNodeType, node.parentMixinTypes, node.parentSupertypes);
        },
        getFields: function(object) {
            var key, value, fieldsArray = [];
            for (key in object) {
                if (object.hasOwnProperty(key)) {
                    value = object[ key ];
                    // For each property/field add an object to the array, with key and value
                    fieldsArray.push({
                        key: key,
                        value: value
                    });
                }
            }
            // Return the array, to be rendered using {{for ~fields(object)}}
            return fieldsArray;
        },
        getParent: function (path) {
            var lastSlashPos = path.lastIndexOf('/');
            if (lastSlashPos > -1) {
                return path.substring(0, lastSlashPos);
            } else {
                return "";
            }
        },
        getPathFromNodeType: function (nodetype) {
            return nodeTypeToPath(nodetype);
        },
        getIconName: function (node) {
            return resolveIconName(node);
        }
    });
}
window.addEventListener('load', function () {
    console.log('load event');

    document.addEventListener('deviceready', function () {
        console.log('deviceready event');
        initApp();
    }, false);
}, false);

