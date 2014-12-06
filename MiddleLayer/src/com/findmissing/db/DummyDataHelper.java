package com.findmissing.db;

public class DummyDataHelper {
	static boolean dataInserted = false;

	public static void insertDummyData(int rows, DummyDB db) {
		if(!dataInserted) {
			dataInserted = true;
			for(int i = 0; i < rows; i++){
				DummyDBNode node = new DummyDBNode();
				node.personid = i;
				for(int j = 0; j < 5; j++){
					node.images.add("images/test" + i + ".jpg");
				}
				node.personName = "test_person" + i;
				db.insertUpdate(i, node);
			}
		}
	}
}
