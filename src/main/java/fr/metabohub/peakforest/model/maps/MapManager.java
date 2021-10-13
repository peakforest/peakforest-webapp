package fr.metabohub.peakforest.model.maps;

import java.util.ArrayList;
import java.util.List;

import javax.persistence.AttributeOverride;
import javax.persistence.CascadeType;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.FetchType;
import javax.persistence.JoinColumn;
import javax.persistence.OneToMany;
import javax.persistence.PrimaryKeyJoinColumn;
import javax.persistence.Table;

@Entity
@Table(name = "map_manager")
@AttributeOverride(name = "id", column = @Column(name = "id_map_manager"))
@PrimaryKeyJoinColumn(name = "id_map_manager")
public class MapManager extends AbstractMapObject {

	// map type
	public static final short MAP_METEXPLORE = 0;

	// public static final short STRATEGY_FIRST = 0;
	// public static final short STRATEGY_MOST_REPRESENTATIVE = 1;
	// public static final short STRATEGY_SPECIFIC_SOURCE = 2;

	// ////////////////////////////////////////////////////////////////////////
	// no database data
	// private Map<String, Short> bioSource2strategy = new HashMap<String, Short>();
	private short defaultStrategy;

	// ////////////////////////////////////////////////////////////////////////
	// database fields

	@Column(name = "map_source", nullable = false, unique = true)
	private Short mapSource;

	@OneToMany(fetch = FetchType.LAZY, cascade = CascadeType.ALL, orphanRemoval = true)
	@JoinColumn(name = "map_manager_id")
	protected List<MapEntity> mapEntities = new ArrayList<MapEntity>();

	// @Column(name = "map_token", nullable = false)
	// private String token;

	public MapManager() {
		this(null);
	}

	public MapManager(Short mapSource) {
		super();
		this.mapSource = mapSource;
		// for (String bioSource : bioSourceKeys)
		// bioSource2strategy.put(bioSource, defaultStrategy);
		mapEntities = new ArrayList<MapEntity>();
	}

	public Short getMapSource() {
		return mapSource;
	}

	public void setMapSource(Short mapSource) {
		this.mapSource = mapSource;
	}

	public List<MapEntity> getMapEntities() {
		return mapEntities;
	}

	public void setMapEntities(List<MapEntity> mapEntities) {
		this.mapEntities = mapEntities;
	}

	public boolean addMapEntities(MapEntity mapEntity) {
		return this.mapEntities.add(mapEntity);
	}

	public short getDefaultStrategy() {
		return defaultStrategy;
	}

	public void setDefaultStrategy(short defaultStrategy) {
		this.defaultStrategy = defaultStrategy;
	}

}
