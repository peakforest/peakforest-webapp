package fr.metabohub.peakforest.utils;

import java.util.ResourceBundle;

import org.junit.Assert;
import org.junit.BeforeClass;
import org.junit.Test;

public class MetExploreRequestJobTest {

	@BeforeClass
	public static void setUpBeforeClass() throws Exception {
		PeakForestUtils.setBundleConf(ResourceBundle.getBundle("confTest"));
	}

	@Test
	public void test() {
		// display log

		// MetExploreRequestJob test = new MetExploreRequestJob();
		try {
			MetExploreRequestJob.updateMappingData(1);
		} catch (Exception e) {
			e.printStackTrace();
			Assert.fail("[fatal] exception occured");
		}

	}

}
