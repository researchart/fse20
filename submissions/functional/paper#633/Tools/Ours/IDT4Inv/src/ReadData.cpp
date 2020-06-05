#define _CRT_SECURE_NO_WARNINGS
#include "ReadData.h"
#include "Config.h"
#include "Program.h"
#include "Log.h"

bool CanReadNamesStop(char* StoppedFlag, char* Line, int Length) {
	for (int i = 0; i < Length; i++) {
		if (*(StoppedFlag + i) != *(Line + i))
			return false;
	}
	return true;
}

int String2int(std::string String) {
	int Value = 0;
	int i = 0;
	if (String[0] == '-') 
		++i;
	for (; i < (int) String.size() 
		&& String[i] >= '0' && String[i] <= '9'; ++i) {
		Value *= 10;
		Value += String[i] - '0';
	}
	if (String[0] == '-')
		return -Value;
	else return Value;
}


ReadState LoadNames(char* FilePrefix) {
	DimensionCount = 0;
	ActualDimensionCount = 0;
	ArtificialDimensionCount = 0;
	Index2Name.clear();
	Name2Index.clear();
	char Names[1024];
	Names[0] = 0;
#ifndef READ_FROM_COMMAND
	strcpy(Names, "data/");
#endif
	strcat(Names, FilePrefix);
	strcat(Names, ".names");
	Log::Info(Format("Names file is %s.",Names));
	FILE* File = fopen(Names, "r");
	if (File == nullptr) {
		Log::Error("Names file is failed to find!");
		Program::stop();
	}
	char *StoppedFlag = new char[MAX_FILE_LINE_BUFFER_SIZE + 10];
	fscanf(File, "%s\n", StoppedFlag);
	int StoppedFlagLength = (int) strlen(StoppedFlag) - 1;
	char *Line = new char[MAX_FILE_LINE_BUFFER_SIZE + 10];
#ifndef TIME_TEST
	Log::Info("Now read the names...");
#endif

	// load loop names.
	fgets(Line, MAX_FILE_LINE_BUFFER_SIZE, File);
	int LineIndex = 0;
	while (Line[LineIndex] != ':')
		++LineIndex;
	++LineIndex;
	while (Line[LineIndex] == ' ')
		++LineIndex;
	std::string LoopName = "";
	int LoopIndex = 0;
	while (Line[LineIndex] != '.'&&Line[LineIndex] != '\n') {
		// todo
		while (Line[LineIndex] != ',' && Line[LineIndex] != '.') {
			LoopName = LoopName + Line[LineIndex];
			++LineIndex;
		}
		if (LoopName[0] != '$') {
			LoopIndex2Name.push_back(LoopName);
			LoopName2Index[LoopName] = LoopIndex;
			++LoopIndex;
		}
		LoopName = "";

		++LineIndex;
		while (Line[LineIndex] == ' ')
			++LineIndex;
	}
	LoopCount = LoopIndex;



	while (fgets(Line, MAX_FILE_LINE_BUFFER_SIZE, File)) {
		if (CanReadNamesStop(StoppedFlag, Line, StoppedFlagLength))
			break;
		
		int NameEnd = 0;
		while (CharacterIsInName(Line[NameEnd]))
			++NameEnd;
		Line[NameEnd] = 0;
		std::string NameThisLine = Line;
		Index2Name.push_back(NameThisLine);
		Name2Index[NameThisLine] = DimensionCount;
		DimensionCalculation NowLineDimensionCalculation;
		if (Line[0] != '$') { //ActualDimensionCount
			++ActualDimensionCount;

			// To support more loops
			std::string LoopName = "";
			int LoopEnd = 0;
			while (Line[LoopEnd] != '$') {
				LoopName = LoopName + Line[LoopEnd];
				++LoopEnd;
			}
			int LoopIndex = LoopName2Index[LoopName];
			DimensionBelongToLoopIndex.push_back(LoopIndex);

			DimensionType.push_back(ACTUAL_DIMENSION);

		}
		else {  //ArtificialDimension
			++ArtificialDimensionCount;
			
			// To support more loops
			std::string LoopName = "";
			int LoopEnd = 1;
			while (Line[LoopEnd] != '$') {
				LoopName = LoopName + Line[LoopEnd];
				++LoopEnd;
			}
			int LoopIndex = LoopName2Index[LoopName];
			DimensionBelongToLoopIndex.push_back(LoopIndex);

			DimensionType.push_back(ARTIFICIAL_DIMENSION);

			while(Line[NameEnd] != '=')
				++NameEnd;
			++NameEnd;
			while(Line[NameEnd] == ' ')
				++NameEnd;
			int value = 1;
			while (true) {
				value = 1;
				while (Line[NameEnd] == ' ')
					++NameEnd;
				if (Line[NameEnd] == '.') {
					break;
				}
				if (Line[NameEnd] == '-') {
					value = -1;
					++NameEnd;
					while (Line[NameEnd] == ' ')
						++NameEnd;
				}
				if (Line[NameEnd] == '+') {
					++NameEnd;
					while (Line[NameEnd] == ' ')
						++NameEnd;
				}
				std::string NowString="";
				while (Line[NameEnd] != ' ' && Line[NameEnd] != '.') {
					NowString += Line[NameEnd];
					++NameEnd;
				}
					
				while (Line[NameEnd] == ' ')
					++NameEnd;
				if (Line[NameEnd] == '*')
				{
					value *= String2int(NowString);
					++NameEnd;
					while (Line[NameEnd] == ' ')
						++NameEnd;
					NowString = "";
					while (Line[NameEnd] != ' ' && Line[NameEnd] != '.') {
						NowString += Line[NameEnd];
						++NameEnd;
					}
						
				}
				NowLineDimensionCalculation
					.push_back(std::make_pair(Name2Index[NowString],value));
			}
		}
		Calculation.push_back(NowLineDimensionCalculation);
		++DimensionCount;
	}
	
	fclose(File);
#ifndef TIME_TEST
	Log::Info("Names have been read!");
#endif
	delete[]Line;
	delete[]StoppedFlag;
	return READ_SUCCESS;
}



ReadState LoadData(char* FilePrefix) {
	char DataBuffer[1024];
	DataBuffer[0] = 0;
#ifndef READ_FROM_COMMAND
	strcpy(DataBuffer, "data/");
#endif
	strcat(DataBuffer, FilePrefix);
	strcat(DataBuffer, ".dup.data");
	Log::Info(Format("DataBuffer file is %s",DataBuffer));
	FILE* File = fopen(DataBuffer, "r");
	if (File == nullptr) {
		Log::Error("DataBuffer file is failed to find!");
		Program::stop();
	}
	char *Line = new char[MAX_FILE_LINE_BUFFER_SIZE + 10];
#ifndef TIME_TEST
	Log::Info("Now read the data...");
#endif
	DataListSaved.clear();
	SampleCount = 0;
	
	while (fgets(Line, MAX_FILE_LINE_BUFFER_SIZE, File)) {
		if (Line[0] == '\n') break;
		int LineIndex = 0;
		// Read a useless attribute.
		while (Line[LineIndex] != ',')
			++LineIndex;
		++LineIndex;
		while (Line[LineIndex] == ' ')
			++LineIndex;
		int LoopIndex = -1;
		Interval *IntervalList = new Interval[DimensionCount + 5];
		for (int AttributeIndex = 0; AttributeIndex < DimensionCount; ++AttributeIndex) {
			if (DimensionType[AttributeIndex] == ACTUAL_DIMENSION) {
				DataType LeftBound, RightBound;
				if (Line[LineIndex] == '?') {
					++LineIndex;
					LeftBound = RightBound = USELESS_DIMENSION;
					while (Line[LineIndex] == ' ')
						++LineIndex;
				}
				else if (Line[LineIndex] == '[' || Line[LineIndex] == '(') {
					if (LoopIndex == -1) {
						LoopIndex = DimensionBelongToLoopIndex[AttributeIndex];
					}
					else {
						assert(LoopIndex == DimensionBelongToLoopIndex[AttributeIndex]);
					}
					++LineIndex;
					std::string Attribute = "";
					while ((Line[LineIndex] >= '0' && Line[LineIndex] <= '9') || Line[LineIndex] == '-') {
						Attribute += Line[LineIndex];
						++LineIndex;
					}
					LeftBound = String2int(Attribute);
					while (Line[LineIndex] != ',')
						++LineIndex;
					++LineIndex;
					while (Line[LineIndex] == ' ')
						++LineIndex;
					Attribute = "";
					while ((Line[LineIndex] >= '0'&&Line[LineIndex] <= '9') || Line[LineIndex] == '-') {
						Attribute += Line[LineIndex];
						++LineIndex;
					}
					RightBound = String2int(Attribute);
					while (Line[LineIndex] != ']' && Line[LineIndex] != ')')
						++LineIndex;
					++LineIndex;
					while (Line[LineIndex] == ' ')
						++LineIndex;
				}
				else if ((Line[LineIndex] >= '0'&&Line[LineIndex] <= '9') || Line[LineIndex] == '-') {
					if (LoopIndex == -1) {
						LoopIndex = DimensionBelongToLoopIndex[AttributeIndex];
					}
					else {
						assert(LoopIndex == DimensionBelongToLoopIndex[AttributeIndex]);
					}
					
					std::string Attribute = "";
					while ((Line[LineIndex] >= '0'&&Line[LineIndex] <= '9') || Line[LineIndex] == '-') {
						Attribute += Line[LineIndex];
						++LineIndex;
					}
					LeftBound = RightBound = String2int(Attribute);
				}
				else {
					Log::Error("Data format is wrong!");
					Program::stop();
				}
				IntervalList[AttributeIndex] = Interval(LeftBound, RightBound);
				while (Line[LineIndex] != ',')
					++LineIndex;
				++LineIndex;
				while (Line[LineIndex] == ' ')
					++LineIndex;

			}
			else if(DimensionType[AttributeIndex] == ARTIFICIAL_DIMENSION) {
				int LinerRelationSize = (int) Calculation[AttributeIndex].size();
				if (LinerRelationSize == 0) {
					Log::Error("No liner relation!");
					Program::stop();
				}
				DataType LeftBound = 0, RightBound = 0;
				if (LoopIndex != DimensionBelongToLoopIndex[AttributeIndex]) {
					IntervalList[AttributeIndex] 
						= Interval(USELESS_DIMENSION, USELESS_DIMENSION);
				}
				for (int LinerRelationItem = 0;
					LinerRelationItem < LinerRelationSize; ++LinerRelationItem) {
					if (Calculation[AttributeIndex][LinerRelationItem].second >= 0) {
						LeftBound += 
							Calculation[AttributeIndex][LinerRelationItem].second *
							IntervalList[Calculation[AttributeIndex]
							[LinerRelationItem].first]
							.LeftBound;
						RightBound +=
							Calculation[AttributeIndex][LinerRelationItem].second *
							IntervalList[Calculation[AttributeIndex]
							[LinerRelationItem].first]
							.RightBound;
					}
					else {
						LeftBound +=
							Calculation[AttributeIndex][LinerRelationItem].second *
							IntervalList[Calculation[AttributeIndex]
							[LinerRelationItem].first]
							.RightBound;
						RightBound +=
							Calculation[AttributeIndex][LinerRelationItem].second *
							IntervalList[Calculation[AttributeIndex]
							[LinerRelationItem].first]
							.LeftBound;
					}
				}

				IntervalList[AttributeIndex] = Interval(LeftBound, RightBound);
			}
			else {
				Log::Error("Logical error!");
				Program::stop();
			}

		}

		std::string LabelString = "";
		while ((Line[LineIndex] >= 'a' && Line[LineIndex] <= 'z')
			|| (Line[LineIndex] >= 'A' && Line[LineIndex] <= 'Z')
			|| Line[LineIndex] == '?') {
			LabelString += Line[LineIndex];
			++LineIndex;
		}
		if (LabelString == "true" 
			|| LabelString == "True" || LabelString == "TRUE") {
#ifndef IMPLICATION
			DataListSaved.push_back(Data(IntervalList, LABEL_TRUE));
#else
			DynamicLabelList.push_back(LABEL_TRUE);
			DataListSaved.push_back(Data(LABEL_TRUE,
				(int) DynamicLabelList.size() - 1, IntervalList));
			DataListSaved[DataListSaved.size() - 1].LoopBelong = LoopIndex;
#endif
		}
		else if (LabelString == "false" 
			|| LabelString == "False" || LabelString == "FALSE") {
#ifndef IMPLICATION
			DataListSaved.push_back(Data(IntervalList, LABEL_FALSE));
#else
			DynamicLabelList.push_back(LABEL_FALSE);
			DataListSaved.push_back(Data(LABEL_FALSE,
				(int)DynamicLabelList.size() - 1, IntervalList));
			DataListSaved[DataListSaved.size() - 1].LoopBelong = LoopIndex;
#endif
		}
		else if (LabelString == "?") {
			
#ifndef IMPLICATION
			Log::Warning("Label is not supported yet!");
			DataListSaved.push_back(Data(IntervalList, LABEL_UNKNOWN));
#else
			DynamicLabelList.push_back(LABEL_UNKNOWN);
			DataListSaved.push_back(Data(LABEL_UNKNOWN,
				(int)DynamicLabelList.size() - 1, IntervalList));
			DataListSaved[DataListSaved.size() - 1].LoopBelong = LoopIndex;
#endif
		}
		else {
			Log::Error("Label  is error!");
			Program::stop();
		}
#ifdef ADDITIONAL_WEIGHT
		DataListSaved[DataListSaved.size() - 1].Size *= (SampleCount + 1);
#endif // ADDITIONAL_WEIGHT
		++SampleCount;
	}



	fclose(File);
#ifndef TIME_TEST
	Log::Info("Data have been read!");
#endif
	delete[]Line;
	return READ_SUCCESS;
}



#ifdef IMPLICATION
ReadState LoadImplications(char* FilePrefix) {
	char DataBuffer[1024];
	DataBuffer[0] = 0;
#ifndef READ_FROM_COMMAND
	strcpy(DataBuffer, "data/");
#endif
	strcat(DataBuffer, FilePrefix);
	strcat(DataBuffer, ".implications");
	Log::Info(Format("Implications file is %s",DataBuffer));
	FILE* File = fopen(DataBuffer, "r");
	if (File == nullptr) {
		Log::Error("Implications file is failed to find!");
		Program::stop();
	}
	char *Line = new char[MAX_FILE_LINE_BUFFER_SIZE + 10];
	ImplicationSet.clear();
#ifndef TIME_TEST
	Log::Info("Now read the implications...");
#endif
	for (int i = 0; i < SampleCount; ++i) {
		DataListSaved[i].FromThisLength = 0;
		DataListSaved[i].ToThisLength = 0;
	}
	// We use FromId and ToId as the DynamicLabelListIndex because when DynamicLabelListIndex<=SampleIndex, it is same.
	int FromId, ToId;
	std::vector<Implication> TmpStorage;
	for (int i = 0; i < SampleCount; ++i) {
		DataListSaved[i].FromThis = new std::vector<int>;
		DataListSaved[i].ToThis = new std::vector<int>;
	}
	while (fscanf(File,"%d%d",&FromId,&ToId)!=EOF) {
		Implication ImplicationItem = std::make_pair(FromId, ToId);
		ImplicationSet.insert(ImplicationItem);
		TmpStorage.push_back(ImplicationItem);
		/*
		++DataListSaved[FromId].FromThisLength;
		++DataListSaved[ToId].ToThisLength;
		*/
		DataListSaved[FromId].FromThis[0].push_back(ToId);
		DataListSaved[ToId].ToThis[0].push_back(FromId);

	}
	/*
	for (int i = 0; i < SampleCount; ++i) {
		if (DataListSaved[i].FromThisLength > 0)
			DataListSaved[i].FromThis = new int[DataListSaved[i].FromThisLength];
		else
			DataListSaved[i].FromThis = nullptr;
		DataListSaved[i].FromThisLength = 0;
		if (DataListSaved[i].ToThisLength > 0)
			DataListSaved[i].ToThis = new int[DataListSaved[i].ToThisLength];
		else
			DataListSaved[i].ToThis = nullptr;
		DataListSaved[i].ToThisLength = 0;
	}
	*/
	//TODO
	int ImplicationCount = (int) TmpStorage.size();
	/*
	for (int i = 0; i < ImplicationCount; ++i) {
		DataListSaved[TmpStorage[i].first].FromThis[DataListSaved[TmpStorage[i].first]
			.FromThisLength] = TmpStorage[i].second;
		++DataListSaved[TmpStorage[i].first].FromThisLength;

		DataListSaved[TmpStorage[i].second].ToThis[DataListSaved[TmpStorage[i].second]
			.ToThisLength] = TmpStorage[i].first;
		++DataListSaved[TmpStorage[i].second].ToThisLength;

	}
	*/
	for (int i = 0; i < SampleCount; ++i) {
		DataListSaved[i].FromThisLength = (int) DataListSaved[i].FromThis[0].size();
		DataListSaved[i].ToThisLength = (int) DataListSaved[i].ToThis[0].size();
	}

	fclose(File);
#ifndef TIME_TEST
	Log::Info("Implications have been read!");
#endif
	return READ_SUCCESS;
}
#endif