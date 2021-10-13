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

	// ////////////////////////////////////////////////////////////////////////
	// map type
	public static final short MAP_METEXPLORE = 0;

	// ////////////////////////////////////////////////////////////////////////
	// no database data

	// ////////////////////////////////////////////////////////////////////////
	// database fields

	@Column(name = "map_source", nullable = false, unique = true)
	private Short mapSource;

	@OneToMany(fetch = FetchType.LAZY, cascade = CascadeType.ALL, orphanRemoval = true)
	@JoinColumn(name = "map_manager_id")
	protected List<MapEntity> mapEntities = new ArrayList<MapEntity>();

	// ////////////////////////////////////////////////////////////////////////
	// constructors

	public MapManager() {
		this(null);
	}

	public MapManager(final Short mapSource) {
		super();
		this.mapSource = mapSource;
		this.mapEntities = new ArrayList<MapEntity>();
	}

	// ////////////////////////////////////////////////////////////////////////
	// accessors

	public boolean addMapEntities(final MapEntity mapEntity) {
		return this.mapEntities.add(mapEntity);
	}

	public int countEntities() {
		return mapEntities.size();
	}

	public List<MapEntity> getMapEntities() {
		return mapEntities;
	}

}
