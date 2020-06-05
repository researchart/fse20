#include "Test.h"

void ShowDataList() {
	printf("\n-----the list of data-----\n\n");
	printf("ID\t");
	for (int i = 0; i < DimensionCount; i++) {
		printf("%s\t", Index2Name[i].c_str());
	}
	printf("LABEL\t");
	printf("\n");
	for (int i = 0; i < SampleCount; i++) {
		printf("%d\t",i);
		for (int j = 0; j < DimensionCount; j++) {
			printf("[%d,%d]\t", DataListSaved[i].Dimension[j].LeftBound, DataListSaved[i].Dimension[j].RightBound);
		}
		if (DataListSaved[i].Label == LABEL_TRUE)
			printf("true\n");
		else if (DataListSaved[i].Label == LABEL_FALSE)
			printf("false\n");
		else printf("?\n");
	}
	printf("\n-----the list of data-----\n\n");
}
