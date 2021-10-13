package fr.metabohub.peakforest.security.services;

import java.util.ArrayList;
import java.util.List;

import org.hibernate.Session;
import org.hibernate.Transaction;
import org.springframework.security.crypto.password.StandardPasswordEncoder;

import fr.metabohub.peakforest.security.dao.UserDao;
import fr.metabohub.peakforest.security.model.User;
import fr.metabohub.peakforest.utils.PeakForestApiHibernateUtils;

/**
 * @author Nils Paulhe
 * 
 */
public class UserManagementService {

	public static long create(final User newUser) throws Exception {
		Long id = null;
		Transaction transaction = null;
		final Session session = PeakForestApiHibernateUtils.getSessionFactory().openSession();
		try {
			transaction = session.beginTransaction();
			id = create(session, newUser);
			transaction.commit();
		} catch (Exception e) {
			transaction.rollback();
			e.printStackTrace();
		} finally {
			session.close();
		}
		return id;
	}

	public static Long create(final Session session, final User user) {
		return UserDao.create(session, user);
	}

	public static User read(final Session session, final long id) throws Exception {
		return UserDao.read(session, id);
	}

	public static User read(final String email) throws Exception {
		return UserDao.read(email);
	}

	public static boolean exists(final String userMail) throws Exception {
		boolean exists = Boolean.FALSE;
		try (final Session session = PeakForestApiHibernateUtils.getSessionFactory().openSession()) {
			exists = UserDao.exists(session, userMail);
		} catch (final Exception e) {
			e.printStackTrace();
		}
		return exists;
	}

	public static List<User> search(String containedString) throws Exception {
		List<User> users = null;
		Transaction transaction = null;
		try (final Session session = PeakForestApiHibernateUtils.getSessionFactory().openSession()) {
			transaction = session.beginTransaction();
			users = UserDao.search(session, containedString);
			transaction.commit();
		} catch (Exception e) {
			transaction.rollback();
			e.printStackTrace();
		}
		return users;
	}

	public static boolean resetPassword(final long userID, final String newPassword) throws Exception {
		boolean success = Boolean.FALSE;
		Transaction transaction = null;
		final Session session = PeakForestApiHibernateUtils.getSessionFactory().openSession();
		try {
			transaction = session.beginTransaction();
			final User user = UserDao.read(session, userID);
			user.setPassword(newPassword);
			transaction.commit();
			success = Boolean.TRUE;
		} catch (final Exception e) {
			transaction.rollback();
			e.printStackTrace();
		} finally {
			session.close();
		}
		return success;
	}

	public static boolean update(final long userID, final String login, final String email) throws Exception {
		Transaction transaction = null;
		boolean success = Boolean.FALSE;
		final Session session = PeakForestApiHibernateUtils.getSessionFactory().openSession();
		try {
			transaction = session.beginTransaction();
			final User user = UserDao.read(session, userID);
			user.setLogin(login);
			user.setEmail(email);
			transaction.commit();
			success = Boolean.TRUE;
		} catch (final Exception e) {
			transaction.rollback();
			e.printStackTrace();
		} finally {
			session.close();
		}
		return success;
	}

	public static boolean updateAdmin(//
			final long userID, //
			final String login, //
			final String email, //
			final int right) throws Exception {
		Transaction transaction = null;
		final Session session = PeakForestApiHibernateUtils.getSessionFactory().openSession();
		boolean success = Boolean.FALSE;
		try {
			transaction = session.beginTransaction();
			final User user = UserDao.read(session, userID);
			user.setLogin(login);
			user.setEmail(email);
			switch (right) {
			case User.NORMAL:
				user.setAdmin(false);
				break;
			case User.ADMIN:
				user.setAdmin(true);
				break;
			default:
				user.setAdmin(false);
				break;
			}
			transaction.commit();
			success = Boolean.TRUE;
		} catch (final Exception e) {
			transaction.rollback();
			e.printStackTrace();
		} finally {
			session.close();
		}
		return success;
	}

	public static boolean changeRight(int right, long userID) throws Exception {
		User user = null;
		Transaction transaction = null;
		final Session session = PeakForestApiHibernateUtils.getSessionFactory().openSession();
		boolean success = Boolean.FALSE;
		try {
			transaction = session.beginTransaction();
			user = UserDao.read(session, userID);
			switch (right) {
			case User.NORMAL:
				user.setCurator(Boolean.FALSE);
				user.setAdmin(Boolean.FALSE);
				break;
			case User.CURATOR:
				user.setCurator(Boolean.TRUE);
				user.setAdmin(Boolean.FALSE);
				break;
			case User.ADMIN:
				user.setCurator(Boolean.TRUE);
				user.setAdmin(Boolean.TRUE);
				break;
			default:
				user.setCurator(Boolean.FALSE);
				user.setAdmin(Boolean.FALSE);
				break;
			}
			transaction.commit();
			success = Boolean.TRUE;
		} catch (final Exception e) {
			transaction.rollback();
			e.printStackTrace();
		} finally {
			session.close();
		}
		return success;

	}

	public static boolean delete(final long userID) throws Exception {
		Transaction transaction = null;
		final Session session = PeakForestApiHibernateUtils.getSessionFactory().openSession();
		boolean success = Boolean.FALSE;
		try {
			transaction = session.beginTransaction();
			UserDao.delete(session, userID);
			transaction.commit();
			success = Boolean.TRUE;
		} catch (final Exception e) {
			transaction.rollback();
			e.printStackTrace();
		} finally {
			session.close();
		}
		return success;
	}

	public static boolean delete(final String email) throws Exception {
		Transaction transaction = null;
		final Session session = PeakForestApiHibernateUtils.getSessionFactory().openSession();
		boolean success = Boolean.FALSE;
		try {
			transaction = session.beginTransaction();
			UserDao.delete(session, email);
			transaction.commit();
			success = Boolean.TRUE;
		} catch (final Exception e) {
			transaction.rollback();
			e.printStackTrace();
		} finally {
			session.close();
		}
		return success;
	}

	public static boolean update(long userID, String login, String email, String userPassword, char userMainTechnology)
			throws Exception {
		User user = null;
		Transaction transaction = null;
		final Session session = PeakForestApiHibernateUtils.getSessionFactory().openSession();
		boolean success = Boolean.FALSE;
		try {
			transaction = session.beginTransaction();
			user = UserDao.read(session, userID);
			user.setLogin(login);
			user.setEmail(email);
			if (userPassword != null) {
				user.setPassword((new StandardPasswordEncoder()).encode(userPassword));
			}
			user.setMainTechnology(userMainTechnology);
			transaction.commit();
			success = Boolean.TRUE;
		} catch (final Exception e) {
			transaction.rollback();
			e.printStackTrace();
		}
		return success;
	}

	public static boolean update(final User user) throws Exception {
		UserDao.update(user);
		return Boolean.TRUE;
	}

	public static User readLogin(final String login) throws Exception {
		return UserDao.readLogin(login);
	}

	public static List<User> search(final String containedString, final int filter) throws Exception {
		final List<User> users = new ArrayList<User>();
		try (final Session session = PeakForestApiHibernateUtils.getSessionFactory().openSession()) {
			users.addAll(UserDao.search(session, containedString, filter));
		} catch (final Exception e) {
			e.printStackTrace();
		}
		return users;
	}

	public static void activate(final long userId) throws Exception {
		Transaction transaction = null;
		final Session session = PeakForestApiHibernateUtils.getSessionFactory().openSession();
		try {
			transaction = session.beginTransaction();
			UserDao.activate(session, userId);
			transaction.commit();
		} catch (Exception e) {
			transaction.rollback();
			e.printStackTrace();
		} finally {
			session.close();
		}
	}

	public static void activateAll() throws Exception {
		Transaction transaction = null;
		final Session session = PeakForestApiHibernateUtils.getSessionFactory().openSession();
		try {
			transaction = session.beginTransaction();
			UserDao.activateAll(session);
			transaction.commit();
		} catch (Exception e) {
			transaction.rollback();
			e.printStackTrace();
		} finally {
			session.close();
		}
	}

	public static void desactivate(final long userId) throws Exception {
		Transaction transaction = null;
		final Session session = PeakForestApiHibernateUtils.getSessionFactory().openSession();
		try {
			transaction = session.beginTransaction();
			UserDao.desactivate(session, userId);
			transaction.commit();
		} catch (final Exception e) {
			transaction.rollback();
			e.printStackTrace();
		} finally {
			session.close();
		}
	}

	public static void activate(final List<Long> ids) throws Exception {
		Transaction transaction = null;
		final Session session = PeakForestApiHibernateUtils.getSessionFactory().openSession();
		try {
			transaction = session.beginTransaction();
			UserDao.activate(session, ids);
			transaction.commit();
		} catch (Exception e) {
			transaction.rollback();
			e.printStackTrace();
		} finally {
			session.close();
		}
	}

	public static String renewToken(final long id) throws Exception {
		String newToken = null;
		Transaction transaction = null;
		final Session session = PeakForestApiHibernateUtils.getSessionFactory().openSession();
		try {
			transaction = session.beginTransaction();
			newToken = UserDao.renewToken(session, id);
			transaction.commit();
		} catch (final Exception e) {
			transaction.rollback();
			e.printStackTrace();
		} finally {
			session.close();
		}
		return newToken;
	}

}
