<?php require_once("header.php"); ?>
    <div class="container">
      <h1>Survey (cont.)</h1>
      
      <form role="form" action="code/validate_page2.php" method="post">
        
        <div class="row">
          <div class="col-lg-4"> <!--left column-->
              
            <div class="form-group">
              <label for="age">How old are you?</label>
              <input type="number" class="form-control" name="age" required>
            </div>

            <div class="form-group">
              <label for="gender">What is your gender:</label>
              <select class="form-control" name="gender" required>
                <option></option>
                <option>Female</option>
                <option>Male</option>
                <option>Other</option>
              </select>
            </div>

            <div class="form-group">
              <label for="internxp">If you had an internship where your job was primarily programming, how many months did you have this internship?</label>
              <input type="number" class="form-control" name="internxp" required>
              <p class="comment">Enter 0 if none.</p>
            </div>

            <div class="course-credit">
              <h4>Course Credit Only</h4>
                <p class="comment">If you have been offered extra credit in a course, please complete this section, otherwise you may omit.</p>

              <div class="form-group">
                <label for="name">Name:</label>
                <input type="text" class="form-control input-md" name="name">
              </div>

              <div class="form-group">
                <label for="courseNum">Course Number:</label>
                <input type="text" class="form-control input-md" name="courseNum">
              </div>

              <div class="form-group">
                <label for="courseName">Course Name:</label>
                <input type="text" class="form-control input-md" name="courseName">
              </div>

              <div class="form-group">
                <label for="instructor">Instructor's Last Name:</label>
                <input type="text" class="form-control input-md" name="instructor">
              </div>
            </div>
              
          </div>
          <div class="col-lg-8 left-pad"> <!--right column-->
            <div class="row">

              <div class="form-group">
                <label>How many <u>years</u> of programming experience do you have in each of the following languages?</label>
                <div class="row">
                  <div class="col-sm-3">
                    <div class="form-inline">
                      <label class="inline-label-sm" for="lang1">C/C++</label>
                      <input type="number" value="0" class="form-control input-sm" name="lang1">
                    </div>
                    <div class="form-inline ">
                      <label class="inline-label-sm" for="lang2">Java</label>
                      <input type="number" value="0" class="form-control input-sm" name="lang2">
                    </div>
                    <div class="form-inline ">
                      <label class="inline-label-sm" for="lang3">Ruby</label>
                      <input type="number" value="0" class="form-control input-sm" name="lang3">
                    </div>
                    <div class="form-inline ">
                      <label class="inline-label-sm" for="lang4">Python</label>
                      <input type="number" value="0" class="form-control input-sm" name="lang4">
                    </div>
                    <div class="form-inline ">
                      <label class="inline-label-sm" for="lang5">PHP</label>
                      <input type="number" value="0" class="form-control input-sm" name="lang5">
                    </div>
                    <div class="form-inline ">
                      <label class="inline-label-sm" for="lang6">Perl</label>
                      <input type="number" value="0" class="form-control input-sm" name="lang6">
                    </div>
                  </div>

                  <div class="col-sm-3">
                    <div class="form-inline ">
                      <label class="inline-label-sm" for="lang7">Fortran</label>
                      <input type="number" value="0" class="form-control input-sm" name="lang7">
                    </div>
                    <div class="form-inline ">
                      <label class="inline-label-sm" for="lang8">COBOL</label>
                      <input type="number" value="0" class="form-control input-sm" name="lang8">
                    </div>
                    <div class="form-inline ">
                      <label class="inline-label-sm" for="lang9">Basic</label>
                      <input type="number" value="0" class="form-control input-sm" name="lang9">
                    </div>
                    <div class="form-inline ">
                      <label class="inline-label-sm" for="lang10">Matlab</label>
                      <input type="number" value="0" class="form-control input-sm" name="lang10">
                    </div>
                    <div class="form-inline ">
                      <label class="inline-label-sm" for="lang11">Go</label>
                      <input type="number" value="0" class="form-control input-sm" name="lang11">
                    </div>
                    <div class="form-inline ">
                      <label class="inline-label-sm" for="lang12">SmallTalk</label>
                      <input type="number" value="0" class="form-control input-sm" name="lang12">
                    </div>
                  </div>

                  <div class="col-sm-3">
                    <div class="form-inline ">
                      <label class="inline-label-sm" for="lang13">C#</label>
                      <input type="number" value="0" class="form-control input-sm" name="lang13">
                    </div>
                    <div class="form-inline ">
                      <label class="inline-label-sm" for="lang14">JavaScript</label>
                      <input type="number" value="0" class="form-control input-sm" name="lang14">
                    </div>
                    <div class="form-inline ">
                      <label class="inline-label-sm" for="lang15">HTML</label>
                      <input type="number" value="0" class="form-control input-sm" name="lang15">
                    </div>
                    <div class="form-inline ">
                      <label class="inline-label-sm" for="lang16">Lisp</label>
                      <input type="number" value="0" class="form-control input-sm" name="lang16">
                    </div>
                    <div class="form-inline ">
                      <label class="inline-label-sm" for="lang17">Scheme</label>
                      <input type="number" value="0" class="form-control input-sm" name="lang17">
                    </div>
                    <div class="form-inline ">
                      <label class="inline-label-sm" for="lang18">Groovy</label>
                      <input type="number" value="0" class="form-control input-sm" name="lang18">
                    </div>
                  </div>
                  <div class="col-sm-3">
                    <div class="form-inline ">
                      <label class="inline-label-sm" for="lang19">Scala</label>
                      <input type="number" value="0" class="form-control input-sm" name="lang19">
                    </div>
                    <div class="form-inline ">
                      <label class="inline-label-sm" for="lang20">R</label>
                      <input type="number" value="0" class="form-control input-sm" name="lang20">
                    </div>
                    <div class="form-inline ">
                      <label class="inline-label-sm" for="lang21">Julia</label>
                      <input type="number" value="0" class="form-control input-sm" name="lang21">
                    </div>
                    <div class="form-inline ">
                      <label class="inline-label-sm" for="lang22">Clojure</label>
                      <input type="number" value="0" class="form-control input-sm" name="lang22">
                    </div>
                    <div class="form-inline ">
                      <label class="inline-label-sm" for="lang23">Quorum</label>
                      <input type="number" value="0" class="form-control input-sm" name="lang23">
                    </div>
		    <div class="form-inline ">
                      <label class="inline-label-sm" for="lang23">SQL</label>
                      <input type="number" value="0" class="form-control input-sm" name="lang24">
                    </div>

                  </div>

                </div>
              </div>

            </div>
              <br>
            <div class="row">

              <div class="form-group">
                <label>Which of the following classes, if any, have you successfully completed or currently enrolled in?  If you have been enrolled in a similar course to any of the following, please pick the best match.</label>
                <div class="form-inline">
                  <label class="inline-label">Intro to Computer Science</label>
                  <label class="radio-inline"><input type="radio" name="course1" value="Complete">Complete</label>
                  <label class="radio-inline"><input type="radio" name="course1" value="Enrolled">Enrolled</label>
                  <label class="radio-inline"><input type="radio" name="course1" value="N/A">N/A</label>
                </div>
                <div class="form-inline">
                  <label class="inline-label">Computer Programming I</label>
                  <label class="radio-inline"><input type="radio" name="course2" value="Complete">Complete</label>
                  <label class="radio-inline"><input type="radio" name="course2" value="Enrolled">Enrolled</label>
                  <label class="radio-inline"><input type="radio" name="course2" value="N/A">N/A</label>
                </div>
                <div class="form-inline">
                  <label class="inline-label">Computer Programming II</label>
                  <label class="radio-inline"><input type="radio" name="course3" value="Complete">Complete</label>
                  <label class="radio-inline"><input type="radio" name="course3" value="Enrolled">Enrolled</label>
                  <label class="radio-inline"><input type="radio" name="course3" value="N/A">N/A</label>
                </div>
                <div class="form-inline">
                  <label class="inline-label">Data Structures</label>
                  <label class="radio-inline"><input type="radio" name="course4" value="Complete">Complete</label>
                  <label class="radio-inline"><input type="radio" name="course4" value="Enrolled">Enrolled</label>
                  <label class="radio-inline"><input type="radio" name="course4" value="N/A">N/A</label>
                </div>
                <div class="form-inline">
                  <label class="inline-label">Algorithms</label>
                  <label class="radio-inline"><input type="radio" name="course5" value="Complete">Complete</label>
                  <label class="radio-inline"><input type="radio" name="course5" value="Enrolled">Enrolled</label>
                  <label class="radio-inline"><input type="radio" name="course5" value="N/A">N/A</label>
                </div>
                <div class="form-inline">
                  <label class="inline-label">Operating Systems</label>
                  <label class="radio-inline"><input type="radio" name="course6" value="Complete">Complete</label>
                  <label class="radio-inline"><input type="radio" name="course6" value="Enrolled">Enrolled</label>
                  <label class="radio-inline"><input type="radio" name="course6" value="N/A">N/A</label>
                </div>
                <div class="form-inline">
                  <label class="inline-label">Computer Architecture</label>
                  <label class="radio-inline"><input type="radio" name="course7" value="Complete">Complete</label>
                  <label class="radio-inline"><input type="radio" name="course7" value="Enrolled">Enrolled</label>
                  <label class="radio-inline"><input type="radio" name="course7" value="N/A">N/A</label>
                </div>
                <div class="form-inline">
                  <label class="inline-label">Programming Languages</label>
                  <label class="radio-inline"><input type="radio" name="course8" value="Complete">Complete</label>
                  <label class="radio-inline"><input type="radio" name="course8" value="Enrolled">Enrolled</label>
                  <label class="radio-inline"><input type="radio" name="course8" value="N/A">N/A</label>
                </div>
                <div class="form-inline">
                  <label class="inline-label">Compilers</label>
                  <label class="radio-inline"><input type="radio" name="course9" value="Complete">Complete</label>
                  <label class="radio-inline"><input type="radio" name="course9" value="Enrolled">Enrolled</label>
                  <label class="radio-inline"><input type="radio" name="course9" value="N/A">N/A</label>
                </div>
                <div class="form-inline">
                  <label class="inline-label">Intro to Statistics</label>
                  <label class="radio-inline"><input type="radio" name="course10" value="Complete">Complete</label>
                  <label class="radio-inline"><input type="radio" name="course10" value="Enrolled">Enrolled</label>
                  <label class="radio-inline"><input type="radio" name="course10" value="N/A">N/A</label>
                </div>
                <div class="form-inline">
                  <label class="inline-label">Advanced Statistics</label>
                  <label class="radio-inline"><input type="radio" name="course11" value="Complete">Complete</label>
                  <label class="radio-inline"><input type="radio" name="course11" value="Enrolled">Enrolled</label>
                  <label class="radio-inline"><input type="radio" name="course11" value="N/A">N/A</label>
                </div>
                <div class="form-inline">
                  <label class="inline-label">Applied Regression Analysis</label>
                  <label class="radio-inline"><input type="radio" name="course12" value="Complete">Complete</label>
                  <label class="radio-inline"><input type="radio" name="course12" value="Enrolled">Enrolled</label>
                  <label class="radio-inline"><input type="radio" name="course12" value="N/A">N/A</label>
                </div>
                <div class="form-inline">
                  <label class="inline-label">Statistics for Scientists</label>
                  <label class="radio-inline"><input type="radio" name="course13" value="Complete">Complete</label>
                  <label class="radio-inline"><input type="radio" name="course13" value="Enrolled">Enrolled</label>
                  <label class="radio-inline"><input type="radio" name="course13" value="N/A">N/A</label>
                </div>
                <div class="form-inline">
                  <label class="inline-label">Experimental Design</label>
                  <label class="radio-inline"><input type="radio" name="course14" value="Complete">Complete</label>
                  <label class="radio-inline"><input type="radio" name="course14" value="Enrolled">Enrolled</label>
                  <label class="radio-inline"><input type="radio" name="course14" value="N/A">N/A</label>
                </div>
                <div class="form-inline">
                  <label class="inline-label">Calculus</label>
                  <label class="radio-inline"><input type="radio" name="course15" value="Complete">Complete</label>
                  <label class="radio-inline"><input type="radio" name="course15" value="Enrolled">Enrolled</label>
                  <label class="radio-inline"><input type="radio" name="course15" value="N/A">N/A</label>
                </div>
                <div class="form-inline">
                  <label class="inline-label">Discrete Mathematics</label>
                  <label class="radio-inline"><input type="radio" name="course16" value="Complete">Complete</label>
                  <label class="radio-inline"><input type="radio" name="course16" value="Enrolled">Enrolled</label>
                  <label class="radio-inline"><input type="radio" name="course16" value="N/A">N/A</label>
                </div>
                <div class="form-inline">
                  <label class="inline-label">Combinatorics</label>
                  <label class="radio-inline"><input type="radio" name="course17" value="Complete">Complete</label>
                  <label class="radio-inline"><input type="radio" name="course17" value="Enrolled">Enrolled</label>
                  <label class="radio-inline"><input type="radio" name="course17" value="N/A">N/A</label>
                </div>
                <div class="form-inline">
                  <label class="inline-label">Linear Algebra</label>
                  <label class="radio-inline"><input type="radio" name="course18" value="Complete">Complete</label>
                  <label class="radio-inline"><input type="radio" name="course18" value="Enrolled">Enrolled</label>
                  <label class="radio-inline"><input type="radio" name="course18" value="N/A">N/A</label>
                </div>
                <div class="form-inline">
                  <label class="inline-label">Probability Theory</label>
                  <label class="radio-inline"><input type="radio" name="course19" value="Complete">Complete</label>
                  <label class="radio-inline"><input type="radio" name="course19" value="Enrolled">Enrolled</label>
                  <label class="radio-inline"><input type="radio" name="course19" value="N/A">N/A</label>
                </div>
                <div class="form-inline">
                  <label class="inline-label">Database Management Systems</label>
                  <label class="radio-inline"><input type="radio" name="course20" value="Complete">Complete</label>
                  <label class="radio-inline"><input type="radio" name="course20" value="Enrolled">Enrolled</label>
                  <label class="radio-inline"><input type="radio" name="course20" value="N/A">N/A</label>
                </div>
             </div>

            </div>
          </div>
        </div>

        <p align="right">
          <button type="submit" class="btn btn-success" style="align">I'm ready to begin the tasks</button>
        </p>
          
      </form>
    </div>

<?php require_once("footer.php"); ?>
