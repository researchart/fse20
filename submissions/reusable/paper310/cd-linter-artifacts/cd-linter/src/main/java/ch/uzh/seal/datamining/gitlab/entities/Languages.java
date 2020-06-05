/**
 * Copyright 2018 University of Zurich
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *     http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package ch.uzh.seal.datamining.gitlab.entities;

import com.google.gson.annotations.SerializedName;

public class Languages {

	private String Java,CSS,TypeScript,HTML,JavaScript,Python,
	Modelica,TeX,Shell,Batchfile,HCL,BitBake,C,Matlab,TXL,XSLT,Perl,Ruby,PowerShell,Pascal,
	ASP,PLpgSQL,Makefile,SQLPL,Puppet,Groovy,M4,Roff,CMake,NSIS,PHP,Go,Smalltalk,Smarty;
	
	@SerializedName("C++")
	private String Cplusplus;
	
	@SerializedName("Objective-C")
	private String ObjectiveC;
	
	@SerializedName("C#")
	private String Csharp;
	
	@SerializedName("Visual Basic")
	private String VisualBasic;

	public String getJava() {
		return Java;
	}

	public void setJava(String java) {
		Java = java;
	}

	public String getCSS() {
		return CSS;
	}

	public void setCSS(String cSS) {
		CSS = cSS;
	}

	public String getTypeScript() {
		return TypeScript;
	}

	public void setTypeScript(String typeScript) {
		TypeScript = typeScript;
	}

	public String getHTML() {
		return HTML;
	}

	public void setHTML(String hTML) {
		HTML = hTML;
	}

	public String getJavaScript() {
		return JavaScript;
	}

	public void setJavaScript(String javaScript) {
		JavaScript = javaScript;
	}

	public String getPython() {
		return Python;
	}

	public void setPython(String python) {
		Python = python;
	}

	public String getModelica() {
		return Modelica;
	}

	public void setModelica(String modelica) {
		Modelica = modelica;
	}

	public String getTeX() {
		return TeX;
	}

	public void setTeX(String teX) {
		TeX = teX;
	}

	public String getShell() {
		return Shell;
	}

	public void setShell(String shell) {
		Shell = shell;
	}

	public String getBatchfile() {
		return Batchfile;
	}

	public void setBatchfile(String batchfile) {
		Batchfile = batchfile;
	}

	public String getHCL() {
		return HCL;
	}

	public void setHCL(String hCL) {
		HCL = hCL;
	}

	public String getBitBake() {
		return BitBake;
	}

	public void setBitBake(String bitBake) {
		BitBake = bitBake;
	}

	public String getC() {
		return C;
	}

	public void setC(String c) {
		C = c;
	}

	public String getMatlab() {
		return Matlab;
	}

	public void setMatlab(String matlab) {
		Matlab = matlab;
	}

	public String getTXL() {
		return TXL;
	}

	public void setTXL(String tXL) {
		TXL = tXL;
	}

	public String getXSLT() {
		return XSLT;
	}

	public void setXSLT(String xSLT) {
		XSLT = xSLT;
	}

	public String getPerl() {
		return Perl;
	}

	public void setPerl(String perl) {
		Perl = perl;
	}

	public String getRuby() {
		return Ruby;
	}

	public void setRuby(String ruby) {
		Ruby = ruby;
	}

	public String getPowerShell() {
		return PowerShell;
	}

	public void setPowerShell(String powerShell) {
		PowerShell = powerShell;
	}

	public String getPascal() {
		return Pascal;
	}

	public void setPascal(String pascal) {
		Pascal = pascal;
	}

	public String getASP() {
		return ASP;
	}

	public void setASP(String aSP) {
		ASP = aSP;
	}

	public String getPLpgSQL() {
		return PLpgSQL;
	}

	public void setPLpgSQL(String pLpgSQL) {
		PLpgSQL = pLpgSQL;
	}

	public String getMakefile() {
		return Makefile;
	}

	public void setMakefile(String makefile) {
		Makefile = makefile;
	}

	public String getSQLPL() {
		return SQLPL;
	}

	public void setSQLPL(String sQLPL) {
		SQLPL = sQLPL;
	}

	public String getPuppet() {
		return Puppet;
	}

	public void setPuppet(String puppet) {
		Puppet = puppet;
	}

	public String getGroovy() {
		return Groovy;
	}

	public void setGroovy(String groovy) {
		Groovy = groovy;
	}

	public String getM4() {
		return M4;
	}

	public void setM4(String m4) {
		M4 = m4;
	}

	public String getRoff() {
		return Roff;
	}

	public void setRoff(String roff) {
		Roff = roff;
	}

	public String getCMake() {
		return CMake;
	}

	public void setCMake(String cMake) {
		CMake = cMake;
	}

	public String getNSIS() {
		return NSIS;
	}

	public void setNSIS(String nSIS) {
		NSIS = nSIS;
	}

	public String getPHP() {
		return PHP;
	}

	public void setPHP(String pHP) {
		PHP = pHP;
	}

	public String getGo() {
		return Go;
	}

	public void setGo(String go) {
		Go = go;
	}

	public String getSmalltalk() {
		return Smalltalk;
	}

	public void setSmalltalk(String smalltalk) {
		Smalltalk = smalltalk;
	}

	public String getSmarty() {
		return Smarty;
	}

	public void setSmarty(String smarty) {
		Smarty = smarty;
	}

	public String getCplusplus() {
		return Cplusplus;
	}

	public void setCplusplus(String cplusplus) {
		Cplusplus = cplusplus;
	}

	public String getObjectiveC() {
		return ObjectiveC;
	}

	public void setObjectiveC(String objectiveC) {
		ObjectiveC = objectiveC;
	}

	public String getCsharp() {
		return Csharp;
	}

	public void setCsharp(String csharp) {
		Csharp = csharp;
	}

	public String getVisualBasic() {
		return VisualBasic;
	}

	public void setVisualBasic(String visualBasic) {
		VisualBasic = visualBasic;
	}
	
	
}
