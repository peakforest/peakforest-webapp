package fr.metabohub.peakforest.utils;

import java.util.ResourceBundle;

import org.junit.Assert;
import org.junit.BeforeClass;
import org.junit.Test;

import fr.metabohub.peakforest.security.model.User;
import fr.metabohub.peakforest.security.services.UserManagementService;

public class UsersToolsTest {

	@BeforeClass
	public static void setUpBeforeClass() {
		PeakForestUtils.setBundleConf(ResourceBundle.getBundle("confTest"));
	}

	@Test
	public void helpTest() {
		String[] arvs = { "-h" };
		try {
			UsersTools.main(arvs);
		} catch (Exception e) {
			e.printStackTrace();
			Assert.fail("[error] test class UserToolsTest failled");
		}

		String[] arvs2 = { "--help" };
		try {
			UsersTools.main(arvs2);
		} catch (Exception e) {
			e.printStackTrace();
			Assert.fail("[error] test class UserToolsTest failled");
		}

	}

	@Test
	public void helpError() {
		String[] arvs = { "-u" };
		try {
			UsersTools.main(arvs);
			Assert.fail("[error] test class UserToolsTest failled");
		} catch (Exception e) {
			// e.printStackTrace();
		}

		String[] arvs2 = { "--username" };
		try {
			UsersTools.main(arvs2);
			Assert.fail("[error] test class UserToolsTest failled");
		} catch (Exception e) {
			// e.printStackTrace();
		}

		String[] arvs3 = { "--username", "toto" };
		try {
			UsersTools.main(arvs3);
			Assert.fail("[error] test class UserToolsTest failled");
		} catch (Exception e) {
			// e.printStackTrace();
		}

		String[] arvs4 = { "--email" };
		try {
			UsersTools.main(arvs4);
			Assert.fail("[error] test class UserToolsTest failled");
		} catch (Exception e) {
			// e.printStackTrace();
		}

		String[] arvs5 = { "-e" };
		try {
			UsersTools.main(arvs5);
			Assert.fail("[error] test class UserToolsTest failled");
		} catch (Exception e) {
			// e.printStackTrace();
		}

	}

	@Test
	public void addTest() throws Exception {

		final long beforeTime = System.currentTimeMillis();

		final String[] arvs = { "-e", "user_" + beforeTime + "", "-p", "thisIsApassword", "-r", "USER" };
		try {
			UsersTools.main(arvs);
		} catch (Exception e) {
			e.printStackTrace();
			Assert.fail("[error] test class UserToolsTest failled" + e.getMessage());
		}
		User u1 = UserManagementService.read("user_" + beforeTime);
		Assert.assertNotNull("test failled", u1);
		Assert.assertEquals("test failled", u1.isAdmin(), false);
		Assert.assertEquals("test failled", u1.isCurator(), false);
		Assert.assertEquals("test failled", u1.isConfirmed(), true);

		String[] arvs2 = { "--email", "user2_" + beforeTime + "", "--password", "thisIsApassword", "--rights",
				"CURATOR" };
		try {
			UsersTools.main(arvs2);
		} catch (Exception e) {
			e.printStackTrace();
			Assert.fail("[error] test class UserToolsTest failled");
		}
		User u2 = UserManagementService.read("user2_" + beforeTime);
		Assert.assertNotNull("test failled", u2);
		Assert.assertEquals("test failled", u2.isAdmin(), false);
		Assert.assertEquals("test failled", u2.isCurator(), true);
		Assert.assertEquals("test failled", u2.isConfirmed(), true);

		String[] arvs3 = { "--email", "user2_" + beforeTime + "", "--password", "thisIsApassword", "--rights",
				"ADMIN" };
		try {
			UsersTools.main(arvs3);
		} catch (Exception e) {
			e.printStackTrace();
			Assert.fail("[error] test class UserToolsTest failled");
		}
		User u3 = UserManagementService.read("user2_" + beforeTime);
		Assert.assertNotNull("test failled", u3);
		Assert.assertEquals("test failled", u3.isAdmin(), true);
		Assert.assertEquals("test failled", u3.isCurator(), true);
		Assert.assertEquals("test failled", u3.isConfirmed(), true);

	}

	// @Test
	// public void manualTest() throws Exception {
	// // init
	// logger.info("[junit test] UserToolsTest -> begin");
	// long beforeTime = System.currentTimeMillis();
	//
	// String[] arvs = {};
	// try {
	// UsersTools.main(arvs);
	// } catch (Exception e) {
	// e.printStackTrace();
	// Assert.fail("[error] test class UserToolsTest failled");
	// }
	//
	// // end
	// double checkDuration = (double) (System.currentTimeMillis() - beforeTime) /
	// 1000;
	// logger.info("[junit test] UserToolsTest -> end, tested in " + checkDuration +
	// " sec.");
	// }

}
