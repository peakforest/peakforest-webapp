package fr.metabohub.peakforest.utils;

import java.util.ResourceBundle;

import org.apache.log4j.Logger;
import org.hibernate.SessionFactory;
import org.junit.Assert;
import org.junit.BeforeClass;
import org.junit.Rule;
import org.junit.Test;
import org.junit.rules.TestName;

/**
 * @author Nils Paulhe
 *
 */
public class UpdateMassVsLogPStatsTest {

	@Rule
	public TestName name = new TestName();

	public Logger logger = Logger.getRootLogger();
	public static SessionFactory testSessionFactory;

	@BeforeClass
	public static void setUpBeforeClass() throws Exception {
		PeakForestUtils.setBundleConf(ResourceBundle.getBundle("confTest"));
	}

	@Test
	public void test() {
		// display log
		logger.info("[junit test] " + name.getMethodName() + " -> begin");
		long beforeTime = System.currentTimeMillis();

		// MetExploreRequestJob test = new MetExploreRequestJob();
		try {
			UpdateMassVsLogPStats.updateMassVsLogPstats();
		} catch (Exception e) {
			e.printStackTrace();
			Assert.fail("[fatal] exception occured");
		}

		double checkDuration = (double) (System.currentTimeMillis() - beforeTime) / 1000;
		logger.info("[junit test] " + name.getMethodName() + " -> end, tested in " + checkDuration + " sec.");
	}

}
