<?php require_once("header.php"); ?>
    <div class="container-fluid">
      <div>
        <h1>Informed Consent Form</h1>
        <h3>TITLE OF STUDY: Scientific Computing Study on Programming Language</h3>
        <h3>INVESTIGATOR(S): Dr. Andreas Stefik, andreas.stefik@unlv.edu</h3>
        <p>For questions regarding the rights of research subjects, any complaints or comments regarding the manner in which the study is being conducted, contact <b>the UNLV Office of Research Integrity – Human Subjects at 702-895-2794, toll free at 877-895-2794 or via email at IRB@unlv.edu.</b></p>
      </div>
      
      <div id="scroll-area">
        <h4>Purpose</h4>
        <p>You are invited to participate in a research study. The purpose of this study is to study programming languages.</p>
        <h4>Participants</h4>
        <p>You are being asked to participate in the study because you fit this criteria: over 18 years old.</p>
        <h4>Procedures</h4>
        <p>If you volunteer to participate in this study, you may be asked to do the following:</p>
        <ol>
          <li>Read about computer programming languages</li>
          <li>Practice doing some computer programming</li>
          <li>Take a survey about programming languages</li>
        </ol>
        <h4>Benefits</h4>
        <p>You may learn about programming languages by participating in this study. Other than possibly contributing to scientific knowledge in the field, there are otherwise no benefits for participation.</p>
        <h4>Risks</h4>
        <p>There are risks involved in all research studies and while this study includes only minimal risks, you may experience some mental distress. Many students that are learning to program a computer find the experience challenging. Computer programming can be very mathematical and might require significant effort. Some students may even find the task of programming itself to be complex and frustrating. Tasks in this study are timed and you may feel uncomfortable with timed tasks. Further, the easiest way for us to gather information about how well our tools are working is to do so electronically. While we will do our best to keep all information confidential, and the information we are collecting is not of a personal nature, no computer security mechanism is perfectly secure.</p>
        <h4>Cost/Compensation</h4>
        <p>There will not be any financial cost to you to participate in this study. You may be offered extra credit in a course for participating.</p>
        <h4>Confidentiality</h4>
        <p>All information gathered in this study will be kept as confidential as possible. No reference will be made in written or oral materials that could link you to this study. All records will be stored in a locked facility at UNLV for 5 years after completion of the study.  Since this study is part     of an international research collaboration, non-identifiable data may also be shared securely to trained research collaborators in the US and Europe.</p>
        <h4>Voluntary Participation</h4>
        <p>Your participation in this study is voluntary. You may refuse to participate in this study or in any part of this study. You may withdraw at any time without prejudice to your relations with UNLV. You may ask questions about this study at the beginning or any time during the research study.</p>
      </div>

      <form role="form" action="code/accept_consent.php" method="post">
        <div class="form-group">
          <h4>Participant Consent</h4>
          <p>I have read the above information and agree to participate in this study. I have been able to ask questions about the research study. I am at least 18 years of age. A copy of this form has been given to me (<a href="documents/Informed Consent Form - Final.pdf">Informed Consent Form</a>).
          </p>
        <button type="submit" class="btn btn-success bt-lg">I Accept</button>
        <button type="button" onclick="window.location.href = 'code/decline_consent.php'" class="btn btn-danger bt-lg">I Decline</button>
        </div>
      </form>
    </div>

<?php require_once("footer.php"); ?>
