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
		try {
			MetExploreRequestJob.updateMappingData();
		} catch (final Exception e) {
			e.printStackTrace();
			Assert.fail("[fatal] exception occured");
		}
	}

}
