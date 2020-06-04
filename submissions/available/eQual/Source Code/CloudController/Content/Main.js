var lngUpFlag, modUpFlag;
function navigateToMonitorPage()
{
    var url=$('#monitorNavigation').prop('href');
    window.location =url;
}
window.onload = function () {
    //------------------------------------------------------------------------------
    // Handling file uploads to the server
    $('#languageButton').bind("click", function () {
        $('#languageFileInput').click();
    });
    $('#modelButton').bind("click", function () {
        $('#modelFileInput').click();
    });

    var progressProp = {
        color: '#ff9800',
        duration: 2000,
        strokeWidth: 7,
        easing: "easeOut"
    };
    var langCircle = new ProgressBar.Circle('#languageUploadProgress', progressProp);
    var modCircle = new ProgressBar.Circle('#modelUploadProgress', progressProp);

    var dropBoxLanguage = document.getElementById("dropBoxLanguage");
    var dropBoxModel = document.getElementById("dropBoxModel");

    function defaults(e) {
        e.stopPropagation();
        e.preventDefault();
    }
    function dragenter(e) {
        $(this).addClass("active");
        defaults(e);
    }
    function dragleave(e) {
        $(this).removeClass("active");
        defaults(e);
    }
    function dragover(e) {
        defaults(e);
    }
    function drop(e) {


        $(this).removeClass("active");
        defaults(e);

        // dataTransfer -> which holds information about the user interaction, including what files (if any) the user dropped on the element to which the event is bound.
        //console.log(e);
        var dt = e.dataTransfer;
        var files = dt.files;
        var type = "UploadModel";
        if ($(this).attr('id').indexOf('Language') != -1) {
            type = "UploadLanguage";
        }
        handleFiles(files, type, e);
    }

    dropBoxModel.addEventListener("dragenter", dragenter, false);
    dropBoxModel.addEventListener("dragleave", dragleave, false);
    dropBoxModel.addEventListener("dragover", dragover, false);
    dropBoxModel.addEventListener("drop", drop, false);

    dropBoxLanguage.addEventListener("dragenter", dragenter, false);
    dropBoxLanguage.addEventListener("dragleave", dragleave, false);
    dropBoxLanguage.addEventListener("dragover", dragover, false);
    dropBoxLanguage.addEventListener("drop", drop, false);

    handleFiles = function (files, type, e) {

        var zipType = /.*zip.*/;
        var file = files[0];
        if (!file.type.match(zipType)) {
            alert("File \"" + file.name + "\" is not a zip file.");
            return false;
        }
        if (parseInt(file.size / 1024) > 1024000) {
            alert("File \"" + file.name + "\" is too big.");
            return false;
        }
        var progressIndicator = "#languageUploadProgress";

        if (type.indexOf("Model") != -1)
            progressIndicator = "#modelUploadProgress";

        //var info = '<div class="preview active-win"><div class="preview-image"><img ></div><div class="progress-holder"><span id="progress"></span></div><span class="percents"></span><div style="float:left;">Uploaded <span class="up-done"></span> KB of ' + parseInt(file.size / 1024) + ' KB</div>';
        $(progressIndicator).show("fast", function () {

            //$(".upload-progress").html(info);


            uploadFile(file, type);
        });

    }

    uploadFile = function (file, type) {

        // check if browser supports file reader object
        var guid = $("#simulationGuid").val();
        if (typeof FileReader !== "undefined") {
            //alert("uploading "+file.name);
            reader = new FileReader();
            reader.onload = function (e) {
                //alert(e.target.result);
                $('.preview img').attr('src', e.target.result).css("width", "70px").css("height", "70px");
            }
            reader.readAsDataURL(file);
            var fileName = file.name;
            xhr = new XMLHttpRequest();

            xhr.open("post", "/Main/" + type + "/?guid=" + guid, true);
            xhr.upload.addEventListener("load", function (event) {
                if (type.indexOf('Model') == -1)
                    modUpFlag = true;
                else {
                    lngUpFlag = true;
                }
            }, false);
            xhr.upload.addEventListener("progress", function (event) {

                if (event.lengthComputable) {
                    if (type.indexOf('Model') == -1)
                        langCircle.animate(event.loaded / file.size);
                    else {
                        modCircle.animate(event.loaded / file.size);
                    }

                    //$("#progress").css("width", (event.loaded / event.total) * 100 + "%");
                    //$(".percents").html(" " + ((event.loaded / event.total) * 100).toFixed() + "%");
                    //$(".up-done").html((parseInt(event.loaded / 1024)).toFixed(0));
                } else {
                    alert("Failed to compute file upload length");
                }
            }, false);

            xhr.onreadystatechange = function (oEvent) {
                if (xhr.readyState === 4) {
                    if (xhr.status === 200) {
                        $("#progress").css("width", "100%");
                        $(".percents").html("100%");
                        $(".up-done").html((parseInt(file.size / 1024)).toFixed(0));
                    } else {
                        alert("Error" + xhr.statusText);
                    }
                }
            };

            // Set headers
            xhr.setRequestHeader("Content-Type", "multipart/form-data");
            xhr.setRequestHeader("X-File-Name", file.name);
            xhr.setRequestHeader("X-File-Size", file.fileSize);
            xhr.setRequestHeader("X-File-Type", file.type);

            if (type.indexOf('Model') == -1) {
                $("#dropBoxLanguage").html("");

            } else {
                $("#dropBoxModel").html("");

            }
            xhr.send(file);

        } else {
            alert("Your browser doesnt support FileReader object");
        }
    }
    $('#optimizationButton').click(function () {
        if (lngUpFlag == true && modUpFlag == true) {

        }
        return;
    });
    $('.dropdown-button').dropdown({
        inDuration: 300,
        outDuration: 225,
        constrain_width: true, // Does not change width of dropdown to that of the activator
        hover: false, // Activate on click
        alignment: 'left', // Aligns dropdown to left or right edge (works with constrain_width)
        gutter: 0, // Spacing from edge
        belowOrigin: true // Displays dropdown below the button
    }
  );
    //Enf of handling file upload to server
    //------------------------------------------------------------------------------


    $('#startAnalysisButton').click(function () {
        //if (lngUpFlag != true || modUpFlag != true) {
        if(false){
            $('#startModal').openModal();
            return;
        } else {
            $('.preloader-wrapper').show("slow",function() {
                $('#firstSection').delay(300).hide(800);
            });
            var guid = $("#simulationGuid").val();
            $.ajax(
            {
                url: '/Main/ExtractModelInformation?guid=' + guid,
                type: "GET"
                
            }).done(function (data) {
                updatePropertiesTable(data);
                $('.preloader-wrapper').hide("slow",function() {
                    $('#propertiesTableSection').delay(300).show("slow");
                });
                
            });
        }

    });
    $('#sendBoundariesButton').click(function() {
        var datas = $('#propertiesTableForm').serialize();
        $.ajax({
            type: "POST",
            url: '/Main/UpdateProperties',
            data: datas
        })
            .done(function(data) {
            if (data == "success") {
                $('#monitorModal').openModal();
                var guid = $("#simulationGuid").val();
                
            }
        });
    });
    

    function updatePropertiesTable(data) {
        $('#propertiesTableSection tbody').html("");
        
        for (i = 0; i < data.length; i++) {
            var row = $('<tr>')
                .append($('<td>')
                    .append(data[i].PrimitiveType)
                ).append($('<td>')
                    .append(data[i].Type)
                ).append($('<td>')
                    .append(data[i].Property)
                ).append($('<td>')
                    .append(data[i].DefaultValue)
                ).append($('<td>')
                    .append('<div class="input-field">' +
                        String.format('<input id="lowerBound{0}" type="text" name="lowerBound{0}" class="validate">', i) +
                        String.format('<label for="lowerBound{0}">Min {1}</label>', i, data[i].Property) +
                        '</div>')
                ).append($('<td>')
                    .append('<div class="input-field">' +
                        String.format('<input id="upperBound{0}" type="text" name="upperBound{0}" class="validate">', i) +
                        String.format('<label for="upperBound{0}">Max {1}</label>', i, data[i].Property) +
                        '</div>')
                ).append($('<td>')
                    .append('<div class="input-field">' +
                        String.format('<input id="distribution{0}" type="text" name="distribution{0}" class="validate">', i) +
                        String.format('<label for="distribution{0}">{1} Exploration Function</label>', i, data[i].Distribution) +
                        '</div>')
                );
            $('#propertiesTableSection tbody').append(row);
        }
    }
};

