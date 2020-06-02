<?php require_once("header.php"); ?>
<div class="container">
  <div class="row">
    <h1> Survey Information </h1>
  </div>
  <div class="row">
    <p> In a computer there is something called a byte, which is a portion of computer memory that contains a sequence of 8 bits. A bit can be either 0 or 1 and multiple bits can be used to represent a number in the computer. For example, the sequence of the 4 bits 0000 represents the number 0 and another sequence 1111 respresents the number 15. A larger sequence of bits can represent a larger range of numbers. The number of bytes, bits and the range of numbers they can represent for an integer as follows:
    </p>
  </div>
  <div class="row">
    <b> Integer: </b>
  </div>
  <div class="row">
    <span class="col-md-3">
      8 bits
    </span>
    <span class="col-md-4">
      1 byte
    </span>
    <span class="col-md-5">
      -128 to 127
    </span>
  </div>
  <div class="row">
    <span class="col-md-3">
      16 bits
    </span>
    <span class="col-md-4">
      2 bytes
    </span>
    <span class="col-md-5">
      -32,768 to 32,767
    </span>
  </div>
  <div class="row">
    <span class="col-md-3">
      32 bits
    </span>
    <span class="col-md-4">
      4 bytes
    </span>
    <span class="col-md-5">
      -2,147,483,648 to 2,147,483,647
    </span>
  </div>
  <div class="row">
    <span class="col-md-3">
      64 bits
    </span>
    <span class="col-md-4">
      8 bytes
    </span>
    <span class="col-md-5">
      -92,233,720,368,54,775,808 to 9,223,372,036,854,775,807
    </span>
  </div>
  <div class="row">
    <span class="col-md-3">
      128 bits
    </span>
    <span class="col-md-4">
      16 bytes
    </span>
    <span class="col-md-5">
      -170,141,183,460,469,231,731,687,303,715,884,105,728 to 170,141,183,460,469,231,731,687,303,715,884,105,727
    </span>
  </div>
  <div class="row">
    <p>
      In many situations, an integer will not suffice. In this case, a real number will be needed and it is represented differently than an integer in the computer. For a real number, we may include a decimal point anywhere in the number and a larger sequence of bits can represent a higher precision decimal point number. The bits, bytes and approximate range of the values a number can hold are as follows:
    </p>
  </div>
  <div class="row">
    <b> Number: </b>
  </div>
  <div class="row">
    <span class="col-md-3">
      32 bits
    </span>
    <span class="col-md-4">
      4 bytes
    </span>
    <span class="col-md-5">
      -2,147,483,648 to 2,147,483,647
    </span>
  </div>
  <div class="row">
    <span class="col-md-3">
      64 bits
    </span>
    <span class="col-md-4">
      8 bytes
    </span>
    <span class="col-md-5">
      -9,223,372,036,854,775,808 to 9,223,372,036,854,775,807
    </span>
  </div>
  <div class="row">
    <span class="col-md-3">
      128 bits
    </span>
    <span class="col-md-4">
      16 bytes
    </span>
    <span class="col-md-5">
      -170,141,183,460,469,231,731,687,303,715,884,105,728 to 170,141,183,460,469,231,731,687,303,715,884,105,727
    </span>
  </div>
  <div class="row">
    <p>
      In this survey, the question will state if we are dealing with an integer or a real number. They will also state the amount of bits and bytes that are being dealt with. You will be analyzing many english words and rating each word on how well you think it represents the given concept.
  </div>
  <div class="row">
    <button type="button" onclick="window.location.href = 'code/ack_survey_3_pre.php'" class="btn btn-primary bt-lg">Got it</button>
    
  </div>
</div>

<?php require_once("footer.php"); ?>
