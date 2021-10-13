/**
 * 
 */
package fr.metabohub.peakforest.security.dao;

import java.math.BigInteger;
import java.security.SecureRandom;
import java.util.Date;
import java.util.List;

import javax.persistence.TypedQuery;

import org.hibernate.HibernateException;
import org.hibernate.Session;
import org.hibernate.Transaction;

import fr.metabohub.peakforest.security.model.User;
import fr.metabohub.peakforest.utils.PeakForestApiHibernateUtils;

/**
 * @author Nils Paulhe
 * 
 */
public class UserDao { // extends ADatasetDao<User>

	public static Long create(final User user) throws HibernateException {
		Transaction transaction = null;
		Long id = null;
		final Session session = PeakForestApiHibernateUtils.getSessionFactory().openSession();
		try {
			transaction = session.beginTransaction();
			id = create(session, user);
			transaction.commit();
		} catch (HibernateException e) {
			transaction.rollback();
			e.printStackTrace();
			throw e;
		} finally {
			session.close();
		}
		return id;
	}

	public static Long create(Session session, User user) throws HibernateException {
		Long id;
		user.setCreated(new Date());
		user.setUpdated(new Date());
		id = (Long) session.save(user);
		return id;
	}

	public static void update(User user) throws HibernateException {
		Transaction transaction = null;
		final Session session = PeakForestApiHibernateUtils.getSessionFactory().openSession();
		try {
			transaction = session.beginTransaction();
			update(session, user);
			transaction.commit();
		} catch (HibernateException e) {
			transaction.rollback();
			e.printStackTrace();
			throw e;
		} finally {
			session.close();
		}
	}

	public static void update(Session session, User user) throws HibernateException {
		user.setUpdated(new Date());
		session.update(user);
	}

	public static User read(Long id) throws HibernateException {
		User user = null;
		try (final Session session = PeakForestApiHibernateUtils.getSessionFactory().openSession()) {
			user = read(session, id);
		} catch (HibernateException e) {
			e.printStackTrace();
			throw e;
		}
		return user;
	}

	public static User read(Session session, Long id) {
		return (User) session.get(User.class, id);
	}

	public static User load(Session session, Long id) {
		return (User) session.load(User.class, id);
	}

	public static User read(String email) throws HibernateException {
		Transaction transaction = null;
		User user = null;
		try (final Session session = PeakForestApiHibernateUtils.getSessionFactory().openSession()) {
			transaction = session.beginTransaction();
			user = read(session, email);
			transaction.commit();
		} catch (HibernateException e) {
			transaction.rollback();
			e.printStackTrace();
			throw e;
		}
		return user;
	}

	public static User read(Session session, String email) throws HibernateException {
		String queryString = "from " + User.class.getSimpleName() + " where email =:email";
		return (User) session.createQuery(queryString).setParameter("email", email).uniqueResult();
	}

	public static boolean exists(Session session, String email) throws HibernateException {
		String hqlQuery = "select count(*) from " + User.class.getSimpleName() + " where email =:email";
		TypedQuery<Long> query = session.createQuery(hqlQuery, Long.class);
		query.setParameter("email", email);
		Long queryResult = query.getSingleResult();
		return queryResult == 1;

	}

	public static boolean exists(String email) throws HibernateException {
		boolean exists = false;
		try (final Session session = PeakForestApiHibernateUtils.getSessionFactory().openSession()) {
			exists = UserDao.exists(session, email);
		} catch (Exception e) {
			e.printStackTrace();
		}
		return exists;
	}

	public static List<User> readAll() {
		List<User> users = null;
		try (final Session session = PeakForestApiHibernateUtils.getSessionFactory().openSession()) {
			users = UserDao.readAll(session);
		} catch (Exception e) {
			e.printStackTrace();
		}
		return users;
	}

	public static List<User> readAll(Session session) {
		return session.createQuery("from " + User.class.getSimpleName(), User.class).list();
	}

	public static List<User> search(Session session, String containedString) {
		String queryString = "from " + User.class.getSimpleName() + " where mail like :containedString";
		return session.createQuery(queryString, User.class)//
				.setParameter("containedString", "%" + containedString + "%")//
				.list();
	}

	public static void delete(Session session, Long id) throws HibernateException {
		User user = read(session, id);
		session.delete(user);
	}

	public static void delete(Session session, String email) throws HibernateException {
		User user = read(session, email);
		session.delete(user);
	}

	public static void delete(String email) throws HibernateException {
		Transaction transaction = null;
		try (final Session session = PeakForestApiHibernateUtils.getSessionFactory().openSession()) {
			transaction = session.beginTransaction();
			delete(session, email);
			transaction.commit();
		} catch (HibernateException e) {
			transaction.rollback();
			e.printStackTrace();
			throw e;
		}
	}

	public static void delete(long id) throws HibernateException {
		Transaction transaction = null;
		try (final Session session = PeakForestApiHibernateUtils.getSessionFactory().openSession()) {
			transaction = session.beginTransaction();
			delete(session, id);
			transaction.commit();
		} catch (HibernateException e) {
			transaction.rollback();
			e.printStackTrace();
			throw e;
		}
	}

	public static User readLogin(String login) throws HibernateException {
		Transaction transaction = null;
		User user = null;
		try (final Session session = PeakForestApiHibernateUtils.getSessionFactory().openSession()) {
			transaction = session.beginTransaction();
			user = readLogin(session, login);
			transaction.commit();
		} catch (HibernateException e) {
			transaction.rollback();
			e.printStackTrace();
			throw e;
		}
		return user;
	}

	public static User readLogin(Session session, String login) throws HibernateException {
		String queryString = "from " + User.class.getSimpleName() + " where login =:login";
		return (User) session.createQuery(queryString).setParameter("login", login).uniqueResult();
	}

	public static List<User> search(Session session, String containedString, int filter) {
		String filername = "1";
		if (filter == User.SEARCH_NOT_ACTIVATED)
			filername = "comfirmed = 0";
		else if (filter == User.SEARCH_ONLY_ACTIVATED)
			filername = "comfirmed = 1";
		String queryString = "from " + User.class.getSimpleName() + " where mail like :containedString and :filtername";
		return session.createQuery(queryString, User.class).setParameter("containedString", "%" + containedString + "%")
				.setParameter("filtername", filername).list();
	}

	public static void activate(Session session, long id) {
		User user = read(session, id);
		user.setConfirmed(true);
	}

	public static void desactivate(Session session, long id) {
		User user = read(session, id);
		user.setConfirmed(false);
	}

	public static void activateAll(Session session) {
		TypedQuery<User> query = session
				.createQuery("update  " + User.class.getSimpleName() + " set confirmed = :confirmed ", User.class);
		query.setParameter("confirmed", true);
		query.executeUpdate();
	}

	public static void activate(Session session, List<Long> ids) {
		TypedQuery<User> query = session.createQuery(
				"update  " + User.class.getSimpleName() + " set confirmed = :confirmed where id IN (:ids) ",
				User.class);
		query.setParameter("confirmed", true);
		query.setParameter("ids", ids);
		query.executeUpdate();
	}

	public static String renewToken(Session session, long id) {
		User user = (User) session.get(User.class, id);
		user.setToken(new BigInteger(130, new SecureRandom()).toString(32));
		session.save(user);
		return user.getToken();

	}

}